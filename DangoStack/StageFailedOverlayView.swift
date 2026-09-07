//
//  StageFailedOverlayView.swift
//  DangoStack
//

import SwiftUI

struct StageFailedOverlayView: View {
    @ObservedObject var appState: AppState
    @ObservedObject var adManager: AdManager

    var body: some View {
        ZStack {
            Color.black.opacity(0.42)
                .ignoresSafeArea()

            VStack(spacing: 14) {
                Text("STAGE FAILED")
                    .font(.system(size: 38, weight: .black, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(DangoTheme.text)
                    .padding(.bottom, 8)
                    .accessibilityAddTraits(.isHeader)

                if !appState.hasUsedRewardedContinue {
                    Button("WATCH AD & CONTINUE") {
                        appState.continueWithRewardedAd()
                    }
                    .buttonStyle(DangoPrimaryButtonStyle())
                    .disabled(!adManager.isRewardedReady || adManager.isPresentingAd)
                    .opacity(adManager.isRewardedReady ? 1 : 0.48)
                    .accessibilityHint(
                        adManager.isRewardedReady
                            ? "Watch an ad to restore one life"
                            : "Rewarded ad is not available"
                    )
                }

                Button("RETRY") {
                    appState.retryStage()
                }
                .buttonStyle(DangoSecondaryButtonStyle())
                .disabled(adManager.isPresentingAd)

                Button("STAGE SELECT") {
                    appState.showStageSelect()
                }
                .buttonStyle(DangoSecondaryButtonStyle())
                .disabled(adManager.isPresentingAd)
            }
            .frame(maxWidth: 330)
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(DangoTheme.background)
            )
            .shadow(color: .black.opacity(0.18), radius: 18, y: 8)
            .padding(.horizontal, 28)
        }
    }
}
