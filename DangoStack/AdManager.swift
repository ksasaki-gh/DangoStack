//
//  AdManager.swift
//  DangoStack
//

import Combine
import GoogleMobileAds
import UIKit

@MainActor
final class AdManager: NSObject, ObservableObject {
    @Published private(set) var isRewardedReady = false
    @Published private(set) var isInterstitialPending = false
    @Published private(set) var isPresentingAd = false

    private enum PresentedAdKind {
        case rewarded
        case interstitial
    }

    private var rewardedAd: RewardedAd?
    private var interstitialAd: InterstitialAd?
    private var presentedAdKind: PresentedAdKind?
    private var rewardedCompletion: ((Bool) -> Void)?
    private var interstitialCompletion: (() -> Void)?
    private var didEarnCurrentReward = false

    private var adsRequestAllowed = false
    private var isSDKInitialized = false
    private var isSDKInitializing = false
    private var isLoadingRewarded = false
    private var isLoadingInterstitial = false
    private var rewardedRetryDelay = AdConfiguration.initialReloadDelay
    private var interstitialRetryDelay = AdConfiguration.initialReloadDelay
    private var rewardedRetryWorkItem: DispatchWorkItem?
    private var interstitialRetryWorkItem: DispatchWorkItem?
    private var lastRewardedPresentationDate: Date?
    private(set) var completedStagesSinceLastInterstitial = 0

    func startIfAllowed(canRequestAds: Bool) {
        guard canRequestAds, AdConfiguration.isConfigured else {
            disableAdRequests()
#if DEBUG
            if canRequestAds && !AdConfiguration.isConfigured {
                print("[AdManager] AdMob identifiers are not configured")
            }
#endif
            return
        }

        adsRequestAllowed = true
        guard !isSDKInitialized, !isSDKInitializing else {
            preloadAdsIfNeeded()
            return
        }

        isSDKInitializing = true
        MobileAds.shared.start()
        isSDKInitializing = false
        isSDKInitialized = true
#if DEBUG
        print("[AdManager] SDK initialized")
#endif
        preloadAdsIfNeeded()
    }

    func recordStageClear() {
        completedStagesSinceLastInterstitial += 1
        isInterstitialPending = completedStagesSinceLastInterstitial
            >= AdConfiguration.interstitialFrequency
    }

    func showRewarded(completion: @escaping (Bool) -> Void) {
        guard adsRequestAllowed,
              !isPresentingAd,
              let rewardedAd,
              let viewController = RootViewControllerProvider.topViewController()
        else {
            completion(false)
            return
        }

        do {
            try rewardedAd.canPresent(from: viewController)
        } catch {
#if DEBUG
            print("[AdManager] Rewarded present failed: \(error.localizedDescription)")
#endif
            clearRewardedAndReload()
            completion(false)
            return
        }

        self.rewardedAd = nil
        isRewardedReady = false
        isPresentingAd = true
        presentedAdKind = .rewarded
        rewardedCompletion = completion
        didEarnCurrentReward = false
        rewardedAd.present(from: viewController) { [weak self] in
            self?.didEarnCurrentReward = true
#if DEBUG
            print("[AdManager] Reward earned")
#endif
        }
    }

    func showInterstitialIfNeeded(
        suppressed: Bool,
        completion: @escaping () -> Void
    ) {
        guard !suppressed,
              adsRequestAllowed,
              isInterstitialPending,
              !isInRewardedCooldown,
              !isPresentingAd,
              let interstitialAd,
              let viewController = RootViewControllerProvider.topViewController()
        else {
            completion()
            return
        }

        do {
            try interstitialAd.canPresent(from: viewController)
        } catch {
#if DEBUG
            print("[AdManager] Interstitial present failed: \(error.localizedDescription)")
#endif
            clearInterstitialAndReload()
            completion()
            return
        }

        self.interstitialAd = nil
        isPresentingAd = true
        presentedAdKind = .interstitial
        interstitialCompletion = completion
        interstitialAd.present(from: viewController)
    }

    private var isInRewardedCooldown: Bool {
        guard let lastRewardedPresentationDate else { return false }
        return Date().timeIntervalSince(lastRewardedPresentationDate)
            < AdConfiguration.interstitialCooldownAfterRewarded
    }

    private func preloadAdsIfNeeded() {
        guard adsRequestAllowed, isSDKInitialized else { return }
        loadRewardedIfNeeded()
        loadInterstitialIfNeeded()
    }

    private func loadRewardedIfNeeded() {
        guard adsRequestAllowed,
              isSDKInitialized,
              rewardedAd == nil,
              !isLoadingRewarded else { return }

        rewardedRetryWorkItem?.cancel()
        rewardedRetryWorkItem = nil
        isLoadingRewarded = true

        Task { [weak self] in
            guard let self else { return }
            do {
                let ad = try await RewardedAd.load(
                    with: AdConfiguration.rewardedAdUnitID,
                    request: Request()
                )
                guard self.adsRequestAllowed else {
                    self.isLoadingRewarded = false
                    return
                }
                ad.fullScreenContentDelegate = self
                self.rewardedAd = ad
                self.isLoadingRewarded = false
                self.isRewardedReady = true
                self.rewardedRetryDelay = AdConfiguration.initialReloadDelay
#if DEBUG
                print("[AdManager] Rewarded loaded")
#endif
            } catch {
                self.isLoadingRewarded = false
                self.isRewardedReady = false
#if DEBUG
                print("[AdManager] Rewarded load failed: \(error.localizedDescription)")
#endif
                self.scheduleRewardedReload()
            }
        }
    }

    private func loadInterstitialIfNeeded() {
        guard adsRequestAllowed,
              isSDKInitialized,
              interstitialAd == nil,
              !isLoadingInterstitial else { return }

        interstitialRetryWorkItem?.cancel()
        interstitialRetryWorkItem = nil
        isLoadingInterstitial = true

        Task { [weak self] in
            guard let self else { return }
            do {
                let ad = try await InterstitialAd.load(
                    with: AdConfiguration.interstitialAdUnitID,
                    request: Request()
                )
                guard self.adsRequestAllowed else {
                    self.isLoadingInterstitial = false
                    return
                }
                ad.fullScreenContentDelegate = self
                self.interstitialAd = ad
                self.isLoadingInterstitial = false
                self.interstitialRetryDelay = AdConfiguration.initialReloadDelay
#if DEBUG
                print("[AdManager] Interstitial loaded")
#endif
            } catch {
                self.isLoadingInterstitial = false
#if DEBUG
                print("[AdManager] Interstitial load failed: \(error.localizedDescription)")
#endif
                self.scheduleInterstitialReload()
            }
        }
    }

    private func scheduleRewardedReload() {
        guard rewardedRetryWorkItem == nil else { return }
        let delay = rewardedRetryDelay
        rewardedRetryDelay = min(
            rewardedRetryDelay * 2,
            AdConfiguration.maximumReloadDelay
        )
        let workItem = DispatchWorkItem { [weak self] in
            self?.rewardedRetryWorkItem = nil
            self?.loadRewardedIfNeeded()
        }
        rewardedRetryWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
    }

    private func scheduleInterstitialReload() {
        guard interstitialRetryWorkItem == nil else { return }
        let delay = interstitialRetryDelay
        interstitialRetryDelay = min(
            interstitialRetryDelay * 2,
            AdConfiguration.maximumReloadDelay
        )
        let workItem = DispatchWorkItem { [weak self] in
            self?.interstitialRetryWorkItem = nil
            self?.loadInterstitialIfNeeded()
        }
        interstitialRetryWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
    }

    private func clearRewardedAndReload() {
        rewardedAd = nil
        isRewardedReady = false
        loadRewardedIfNeeded()
    }

    private func disableAdRequests() {
        adsRequestAllowed = false
        rewardedRetryWorkItem?.cancel()
        interstitialRetryWorkItem?.cancel()
        rewardedRetryWorkItem = nil
        interstitialRetryWorkItem = nil
        rewardedAd = nil
        interstitialAd = nil
        isRewardedReady = false
    }

    private func clearInterstitialAndReload() {
        interstitialAd = nil
        loadInterstitialIfNeeded()
    }

    private func finishRewardedPresentation() {
        let completion = rewardedCompletion
        let didEarnReward = didEarnCurrentReward
        rewardedCompletion = nil
        didEarnCurrentReward = false
        presentedAdKind = nil
        isPresentingAd = false
        clearRewardedAndReload()
        completion?(didEarnReward)
    }

    private func finishInterstitialPresentation() {
        let completion = interstitialCompletion
        interstitialCompletion = nil
        presentedAdKind = nil
        isPresentingAd = false
        clearInterstitialAndReload()
        completion?()
    }
}

extension AdManager: FullScreenContentDelegate {
    func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        switch presentedAdKind {
        case .rewarded:
            lastRewardedPresentationDate = Date()
        case .interstitial:
            completedStagesSinceLastInterstitial = 0
            isInterstitialPending = false
#if DEBUG
            print("[AdManager] Interstitial shown")
#endif
        case .none:
            break
        }
    }

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        switch presentedAdKind {
        case .rewarded:
            finishRewardedPresentation()
        case .interstitial:
            finishInterstitialPresentation()
        case .none:
            break
        }
    }

    func ad(
        _ ad: FullScreenPresentingAd,
        didFailToPresentFullScreenContentWithError error: Error
    ) {
#if DEBUG
        print("[AdManager] Ad present failed: \(error.localizedDescription)")
#endif
        switch presentedAdKind {
        case .rewarded:
            didEarnCurrentReward = false
            finishRewardedPresentation()
        case .interstitial:
            finishInterstitialPresentation()
        case .none:
            break
        }
    }
}
