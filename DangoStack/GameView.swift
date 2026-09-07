//
//  GameView.swift
//  DangoStack
//

import SpriteKit
import SwiftUI

struct GameView: View {
    private let scene: DangoGameScene

    init(
        stageNumber: Int = 1,
        onStageCleared: @escaping (StageResult) -> Void = { _ in },
        onStageFailed: @escaping () -> Void = {}
    ) {
        let stageManager = StageManager(initialStageNumber: stageNumber)
        let scene = DangoGameScene(
            size: CGSize(width: 390, height: 844),
            stageManager: stageManager
        )
        scene.scaleMode = .resizeFill
        scene.onStageCleared = onStageCleared
        scene.onStageFailed = onStageFailed
        self.scene = scene
    }

    var body: some View {
        SpriteView(scene: scene)
            .ignoresSafeArea()
    }
}

#Preview {
    GameView()
}
