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
                GameView(
                    stageNumber: stageNumber,
                    onStageCleared: { result in
                        appState.receiveStageClear(
                            result,
                            stageNumber: stageNumber
                        )
                    },
                    onStageFailed: {
                        appState.receiveStageFailure(stageNumber: stageNumber)
                    }
                )
                .id(stageNumber)
            case .result:
                if let outcome = appState.latestOutcome {
                    ResultView(appState: appState, outcome: outcome)
                } else {
                    TitleView(appState: appState)
                }
            }
        }
        .animation(.easeInOut(duration: 0.18), value: appState.screen)
    }
}

#Preview {
    ContentView()
}
