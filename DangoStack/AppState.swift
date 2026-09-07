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

    let saveManager: SaveManager
    let settingsStore: SettingsStore
    let soundManager: SoundManager
    let hapticManager: HapticManager

    init() {
        let settingsStore = SettingsStore()
        saveManager = SaveManager()
        self.settingsStore = settingsStore
        soundManager = SoundManager(settingsStore: settingsStore)
        hapticManager = HapticManager(settingsStore: settingsStore)
    }

    init(saveManager: SaveManager, settingsStore: SettingsStore) {
        self.saveManager = saveManager
        self.settingsStore = settingsStore
        soundManager = SoundManager(settingsStore: settingsStore)
        hapticManager = HapticManager(settingsStore: settingsStore)
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
        gameOverlay = .none
        latestOutcome = nil
        screen = .title
    }

    func showStageSelect() {
        gameOverlay = .none
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

        saveManager.recordStageClear(stageNumber: stageNumber, result: result)
        gameOverlay = .none
        latestOutcome = .cleared(result)
        screen = .result
    }

    func receiveStageFailure(stageNumber: Int) {
        guard screen == .game, selectedStageNumber == stageNumber else { return }

        gameOverlay = .none
        latestOutcome = .failed
        screen = .result
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
        gameOverlay = .none
        gameSessionID = UUID()
        screen = .game
    }
}
