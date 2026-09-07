//
//  AppState.swift
//  DangoStack
//

import Combine
import SwiftUI

enum AppScreen: Equatable {
    case title
    case stageSelect
    case game
    case result
    case settings
}

enum GameOverlay: Equatable {
    case none
    case pause
    case settings
    case failed
}

enum GameOutcome: Equatable {
    case cleared(StageResult)
    case failed
}

@MainActor
final class AppState: ObservableObject {
    @Published private(set) var screen = AppScreen.title
    @Published private(set) var selectedStageNumber = 1
    @Published private(set) var latestOutcome: GameOutcome?
    @Published private(set) var gameOverlay = GameOverlay.none
    @Published private(set) var gameSessionID = UUID()
    @Published private(set) var isTutorialSession = false
    @Published private(set) var rewardedContinueRequestID = UUID()
    @Published private(set) var hasUsedRewardedContinue = false
    @Published private(set) var isResultTransitionInProgress = false

    let saveManager: SaveManager
    let settingsStore: SettingsStore
    let tutorialStore: TutorialStore
    let soundManager: SoundManager
    let hapticManager: HapticManager
    let consentManager: ConsentManager
    let adManager: AdManager

    private var suppressInterstitialForCurrentResult = false

    init() {
        let settingsStore = SettingsStore()
        saveManager = SaveManager()
        self.settingsStore = settingsStore
        tutorialStore = TutorialStore()
        soundManager = SoundManager(settingsStore: settingsStore)
        hapticManager = HapticManager(settingsStore: settingsStore)
        consentManager = ConsentManager()
        adManager = AdManager()
    }

    init(
        saveManager: SaveManager,
        settingsStore: SettingsStore,
        tutorialStore: TutorialStore
    ) {
        self.saveManager = saveManager
        self.settingsStore = settingsStore
        self.tutorialStore = tutorialStore
        soundManager = SoundManager(settingsStore: settingsStore)
        hapticManager = HapticManager(settingsStore: settingsStore)
        consentManager = ConsentManager()
        adManager = AdManager()
    }

    var isGamePaused: Bool {
        gameOverlay != .none
    }

    func play() {
        guard !saveManager.hasClearedAllStages else {
            showStageSelect()
            return
        }

        startStage(saveManager.unlockedStage)
    }

    func showTitle() {
        if shouldRouteResultTransition {
            performResultTransition { [weak self] in
                self?.showTitleImmediately()
            }
            return
        }
        showTitleImmediately()
    }

    private func showTitleImmediately() {
        gameOverlay = .none
        isTutorialSession = false
        latestOutcome = nil
        screen = .title
    }

    func showStageSelect() {
        if shouldRouteResultTransition {
            performResultTransition { [weak self] in
                self?.showStageSelectImmediately()
            }
            return
        }
        showStageSelectImmediately()
    }

    private func showStageSelectImmediately() {
        gameOverlay = .none
        isTutorialSession = false
        latestOutcome = nil
        screen = .stageSelect
    }

    func showSettingsFromTitle() {
        guard screen == .title else { return }
        screen = .settings
    }

    func closeTitleSettings() {
        guard screen == .settings else { return }
        screen = .title
    }

    func selectStage(_ stageNumber: Int) {
        guard saveManager.isUnlocked(stageNumber) else { return }
        startStage(stageNumber)
    }

    func receiveStageClear(_ result: StageResult, stageNumber: Int) {
        guard screen == .game, selectedStageNumber == stageNumber else { return }

        let isFirstStage21Clear = stageNumber
            == StageManager.validStageNumbers.upperBound
            && saveManager.bestStars(for: stageNumber) == 0
        suppressInterstitialForCurrentResult = isTutorialSession
            || isFirstStage21Clear
        completeTutorialAfterStageClear()
        saveManager.recordStageClear(stageNumber: stageNumber, result: result)
        adManager.recordStageClear()
        gameOverlay = .none
        latestOutcome = .cleared(result)
        screen = .result
    }

    func receiveStageFailure(stageNumber: Int) {
        guard screen == .game, selectedStageNumber == stageNumber else { return }

        gameOverlay = .failed
        latestOutcome = .failed
    }

    func pauseGame() {
        guard screen == .game, gameOverlay == .none else { return }
        gameOverlay = .pause
    }

    func resumeGame() {
        guard screen == .game, gameOverlay == .pause else { return }
        gameOverlay = .none
    }

    func showSettingsFromPause() {
        guard screen == .game, gameOverlay == .pause else { return }
        gameOverlay = .settings
    }

    func closePauseSettings() {
        guard screen == .game, gameOverlay == .settings else { return }
        gameOverlay = .pause
    }

    func restartPausedStage() {
        guard screen == .game, isGamePaused else { return }
        retryStage()
    }

    func configureAdvertising() async {
        guard AdConfiguration.isConfigured else { return }
        await consentManager.gatherConsent()
        adManager.startIfAllowed(canRequestAds: consentManager.canRequestAds)
    }

    func showPrivacyOptions() async {
        await consentManager.presentPrivacyOptions()
        adManager.startIfAllowed(canRequestAds: consentManager.canRequestAds)
    }

    func continueWithRewardedAd() {
        guard screen == .game,
              gameOverlay == .failed,
              !hasUsedRewardedContinue,
              adManager.isRewardedReady else { return }

        let sessionID = gameSessionID
        adManager.showRewarded { [weak self] didEarnReward in
            guard let self,
                  didEarnReward,
                  self.screen == .game,
                  self.gameOverlay == .failed,
                  self.gameSessionID == sessionID else { return }

            self.hasUsedRewardedContinue = true
            self.rewardedContinueRequestID = UUID()
            self.gameOverlay = .none
        }
    }

    func completeTutorialAfterStageClear() {
        guard isTutorialSession else { return }
        tutorialStore.markAsSeen()
    }

    func replayTutorial() {
        tutorialStore.resetForReplay()
        startStage(StageManager.validStageNumbers.lowerBound)
    }

    func retryStage() {
        if shouldRouteResultTransition {
            let stageNumber = selectedStageNumber
            performResultTransition { [weak self] in
                self?.startStage(stageNumber)
            }
            return
        }
        startStage(selectedStageNumber)
    }

    func playNextStage() {
        let nextStageNumber = selectedStageNumber + 1
        guard saveManager.isUnlocked(nextStageNumber) else { return }
        performResultTransition { [weak self] in
            self?.startStage(nextStageNumber)
        }
    }

    private func startStage(_ stageNumber: Int) {
        guard StageManager.isValid(stageNumber: stageNumber) else { return }

        selectedStageNumber = stageNumber
        isTutorialSession = stageNumber == StageManager.validStageNumbers.lowerBound
            && !tutorialStore.hasSeenTutorial
        latestOutcome = nil
        gameOverlay = .none
        hasUsedRewardedContinue = false
        isResultTransitionInProgress = false
        suppressInterstitialForCurrentResult = false
        gameSessionID = UUID()
        screen = .game
    }

    private var shouldRouteResultTransition: Bool {
        guard screen == .result,
              case .cleared? = latestOutcome else { return false }
        return true
    }

    private func performResultTransition(
        _ transition: @escaping () -> Void
    ) {
        guard shouldRouteResultTransition,
              !isResultTransitionInProgress else { return }

        isResultTransitionInProgress = true
        adManager.showInterstitialIfNeeded(
            suppressed: suppressInterstitialForCurrentResult
        ) { [weak self] in
            guard let self else { return }
            self.isResultTransitionInProgress = false
            transition()
        }
    }
}
