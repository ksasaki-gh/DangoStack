//
//  GameView.swift
//  DangoStack
//

import Combine
import SpriteKit
import SwiftUI

@MainActor
private final class GameSceneController: ObservableObject {
    let scene: DangoGameScene
    @Published private(set) var canPause = true

    init(
        stageNumber: Int,
        soundManager: SoundManager,
        hapticManager: HapticManager,
        showsTutorial: Bool,
        onStageCleared: @escaping (StageResult) -> Void,
        onStageFailed: @escaping () -> Void,
        onTutorialStageCleared: @escaping () -> Void
    ) {
        let stageManager = StageManager(initialStageNumber: stageNumber)
        let scene = DangoGameScene(
            size: CGSize(width: 390, height: 844),
            stageManager: stageManager,
            soundManager: soundManager,
            hapticManager: hapticManager,
            showsTutorial: showsTutorial
        )
        scene.scaleMode = .resizeFill
        scene.onStageCleared = onStageCleared
        scene.onStageFailed = onStageFailed
        scene.onTutorialStageCleared = onTutorialStageCleared
        self.scene = scene
        scene.onGameEnded = { [weak self] in
            self?.canPause = false
        }
        hapticManager.prepareForGameplay()
    }

    func setPaused(_ isPaused: Bool) {
        scene.setGamePaused(isPaused)
    }

    func continueAfterRewardedAd() {
        scene.continueAfterRewardedAd()
        canPause = true
    }
}

struct GameView: View {
    @StateObject private var controller: GameSceneController

    let isPaused: Bool
    let rewardedContinueRequestID: UUID
    let onPauseRequested: () -> Void

    init(
        stageNumber: Int,
        soundManager: SoundManager,
        hapticManager: HapticManager,
        showsTutorial: Bool,
        isPaused: Bool,
        rewardedContinueRequestID: UUID,
        onPauseRequested: @escaping () -> Void,
        onStageCleared: @escaping (StageResult) -> Void,
        onStageFailed: @escaping () -> Void,
        onTutorialStageCleared: @escaping () -> Void
    ) {
        _controller = StateObject(
            wrappedValue: GameSceneController(
                stageNumber: stageNumber,
                soundManager: soundManager,
                hapticManager: hapticManager,
                showsTutorial: showsTutorial,
                onStageCleared: onStageCleared,
                onStageFailed: onStageFailed,
                onTutorialStageCleared: onTutorialStageCleared
            )
        )
        self.isPaused = isPaused
        self.rewardedContinueRequestID = rewardedContinueRequestID
        self.onPauseRequested = onPauseRequested
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            SpriteView(scene: controller.scene)
                .ignoresSafeArea()

            Button(action: onPauseRequested) {
                Image(systemName: "pause.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(DangoTheme.text)
                    .frame(width: 38, height: 38)
                    .background(.white.opacity(0.72), in: Circle())
                    .overlay {
                        Circle()
                            .stroke(DangoTheme.text.opacity(0.14), lineWidth: 1)
                    }
            }
            .buttonStyle(.plain)
            .disabled(isPaused || !controller.canPause)
            .opacity(controller.canPause ? 1 : 0)
            .padding(.top, 8)
            .padding(.trailing, 16)
            .accessibilityLabel("Pause")
        }
        .onAppear {
            controller.setPaused(isPaused)
        }
        .onChange(of: isPaused) { _, newValue in
            controller.setPaused(newValue)
        }
        .onChange(of: rewardedContinueRequestID) { _, _ in
            controller.continueAfterRewardedAd()
        }
    }
}

#Preview {
    let settingsStore = SettingsStore()
    GameView(
        stageNumber: 1,
        soundManager: SoundManager(settingsStore: settingsStore),
        hapticManager: HapticManager(settingsStore: settingsStore),
        showsTutorial: false,
        isPaused: false,
        rewardedContinueRequestID: UUID(),
        onPauseRequested: {},
        onStageCleared: { _ in },
        onStageFailed: {},
        onTutorialStageCleared: {}
    )
}
