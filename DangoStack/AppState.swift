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

struct StageProgress: Equatable {
    private(set) var highestUnlockedStage = 1
    private(set) var bestStarsByStage: [Int: Int] = [:]
    private(set) var perfectClearStages: Set<Int> = []

    var hasClearedAllStages: Bool {
        bestStarsByStage[StageManager.validStageNumbers.upperBound] != nil
    }

    func isUnlocked(_ stageNumber: Int) -> Bool {
        StageManager.isValid(stageNumber: stageNumber)
            && stageNumber <= highestUnlockedStage
    }

    func bestStars(for stageNumber: Int) -> Int? {
        bestStarsByStage[stageNumber]
    }

    func hasPerfectClear(for stageNumber: Int) -> Bool {
        perfectClearStages.contains(stageNumber)
    }

    mutating func recordClear(stageNumber: Int, result: StageResult) {
        guard StageManager.isValid(stageNumber: stageNumber) else { return }

        let previousBest = bestStarsByStage[stageNumber] ?? 0
        bestStarsByStage[stageNumber] = max(previousBest, result.stars)

        if result.isPerfectClear {
            perfectClearStages.insert(stageNumber)
        }

        if stageNumber < StageManager.validStageNumbers.upperBound {
            highestUnlockedStage = max(highestUnlockedStage, stageNumber + 1)
        }
    }
}

@MainActor
final class AppState: ObservableObject {
    @Published private(set) var screen = AppScreen.title
    @Published private(set) var selectedStageNumber = 1
    @Published private(set) var latestOutcome: GameOutcome?
    @Published private(set) var progress = StageProgress()

    func play() {
        guard !progress.hasClearedAllStages else {
            showStageSelect()
            return
        }

        startStage(progress.highestUnlockedStage)
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
        guard progress.isUnlocked(stageNumber) else { return }
        startStage(stageNumber)
    }

    func receiveStageClear(_ result: StageResult, stageNumber: Int) {
        guard screen == .game, selectedStageNumber == stageNumber else { return }

        var updatedProgress = progress
        updatedProgress.recordClear(stageNumber: stageNumber, result: result)
        progress = updatedProgress
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
        guard progress.isUnlocked(nextStageNumber) else { return }
        startStage(nextStageNumber)
    }

    private func startStage(_ stageNumber: Int) {
        guard StageManager.isValid(stageNumber: stageNumber) else { return }

        selectedStageNumber = stageNumber
        latestOutcome = nil
        screen = .game
    }
}
