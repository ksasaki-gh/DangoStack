//
//  ConsentManager.swift
//  DangoStack
//

import Combine
import UserMessagingPlatform

@MainActor
final class ConsentManager: ObservableObject {
    @Published private(set) var canRequestAds = false
    @Published private(set) var isPrivacyOptionsRequired = false

    private var hasRequestedConsentInfo = false

    func gatherConsent() async {
        guard !hasRequestedConsentInfo else {
            refreshPublishedState()
            return
        }
        hasRequestedConsentInfo = true

        do {
            let parameters = RequestParameters()
            try await ConsentInformation.shared.requestConsentInfoUpdate(
                with: parameters
            )
            refreshPublishedState()

            try await ConsentForm.loadAndPresentIfRequired(
                from: RootViewControllerProvider.topViewController()
            )
        } catch {
#if DEBUG
            print("[ConsentManager] Consent flow failed: \(error.localizedDescription)")
#endif
        }

        refreshPublishedState()
    }

    func presentPrivacyOptions() async {
        guard isPrivacyOptionsRequired else { return }

        do {
            try await ConsentForm.presentPrivacyOptionsForm(
                from: RootViewControllerProvider.topViewController()
            )
        } catch {
#if DEBUG
            print("[ConsentManager] Privacy options failed: \(error.localizedDescription)")
#endif
        }

        refreshPublishedState()
    }

    private func refreshPublishedState() {
        let consentInformation = ConsentInformation.shared
        canRequestAds = consentInformation.canRequestAds
        isPrivacyOptionsRequired =
            consentInformation.privacyOptionsRequirementStatus == .required
    }
}
