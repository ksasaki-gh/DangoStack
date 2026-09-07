//
//  ContentView.swift
//  DangoStack
//
//  Created by EverGreen on 2026/09/01.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appState = AppState()

    var body: some View {
        Group {
            switch appState.screen {
            case .title:
                TitleView(appState: appState)
            case .stageSelect:
                StageSelectView(appState: appState)
            case .game:
                let stageNumber = appState.selectedStageNumber
                ZStack {
                    GameView(
                        stageNumber: stageNumber,
                        soundManager: appState.soundManager,
                        hapticManager: appState.hapticManager,
                        showsTutorial: appState.isTutorialSession,
                        isPaused: appState.isGamePaused,
                        rewardedContinueRequestID: appState.rewardedContinueRequestID,
                        onPauseRequested: appState.pauseGame,
                        onStageCleared: { result in
                            appState.receiveStageClear(
                                result,
                                stageNumber: stageNumber
                            )
                        },
                        onStageFailed: {
                            appState.receiveStageFailure(stageNumber: stageNumber)
                        },
                        onTutorialStageCleared: {
                            appState.completeTutorialAfterStageClear()
                        }
                    )
                    .id(appState.gameSessionID)

                    switch appState.gameOverlay {
                    case .none:
                        EmptyView()
                    case .pause:
                        PauseOverlayView(
                            onResume: appState.resumeGame,
                            onRestart: appState.restartPausedStage,
                            onSettings: appState.showSettingsFromPause,
                            onStageSelect: appState.showStageSelect
                        )
                        .transition(.opacity)
                    case .settings:
                        SettingsView(
                            settingsStore: appState.settingsStore,
                            consentManager: appState.consentManager,
                            onBack: appState.closePauseSettings,
                            onReplayTutorial: appState.replayTutorial,
                            onPrivacyOptions: {
                                Task { await appState.showPrivacyOptions() }
                            }
                        )
                        .transition(.opacity)
                    case .failed:
                        StageFailedOverlayView(
                            appState: appState,
                            adManager: appState.adManager
                        )
                        .transition(.opacity)
                    }
                }
            case .result:
                if let outcome = appState.latestOutcome {
                    ResultView(appState: appState, outcome: outcome)
                } else {
                    TitleView(appState: appState)
                }
            case .settings:
                SettingsView(
                    settingsStore: appState.settingsStore,
                    consentManager: appState.consentManager,
                    onBack: appState.closeTitleSettings,
                    onReplayTutorial: appState.replayTutorial,
                    onPrivacyOptions: {
                        Task { await appState.showPrivacyOptions() }
                    }
                )
            }
        }
        .animation(.easeInOut(duration: 0.18), value: appState.screen)
        .task {
            await appState.configureAdvertising()
        }
    }
}

#Preview {
    ContentView()
}
