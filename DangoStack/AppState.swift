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

    let saveManager: SaveManager

    init() {
        saveManager = SaveManager()
    }

    init(saveManager: SaveManager) {
        self.saveManager = saveManager
    }

    func play() {
        guard !saveManager.hasClearedAllStages else {
            showStageSelect()
            return
        }

        startStage(saveManager.unlockedStage)
    }

    func showTitle() {
        latestOutcome = nil
        screen = .title
    }

    func showStageSelect() {
        latestOutcome = nil
        screen = .stageSelect
    }

    func selectStage(_ stageNumber: Int) {
        guard saveManager.isUnlocked(stageNumber) else { return }
        startStage(stageNumber)
    }

    func receiveStageClear(_ result: StageResult, stageNumber: Int) {
        guard screen == .game, selectedStageNumber == stageNumber else { return }

        saveManager.recordStageClear(stageNumber: stageNumber, result: result)
        latestOutcome = .cleared(result)
        screen = .result
    }

    func receiveStageFailure(stageNumber: Int) {
        guard screen == .game, selectedStageNumber == stageNumber else { return }

        latestOutcome = .failed
        screen = .result
    }

    func retryStage() {
        startStage(selectedStageNumber)
    }

    func playNextStage() {
        let nextStageNumber = selectedStageNumber + 1
        guard saveManager.isUnlocked(nextStageNumber) else { return }
        startStage(nextStageNumber)
    }

    private func startStage(_ stageNumber: Int) {
        guard StageManager.isValid(stageNumber: stageNumber) else { return }

        selectedStageNumber = stageNumber
        latestOutcome = nil
        screen = .game
    }
}
