//
//  GameView.swift
//  DangoStack
//

import SpriteKit
import SwiftUI

struct GameView: View {
    private let scene: DangoGameScene = {
        let scene = DangoGameScene(size: CGSize(width: 390, height: 844))
        scene.scaleMode = .resizeFill
        return scene
    }()

    var body: some View {
        SpriteView(scene: scene)
            .ignoresSafeArea()
    }
}

#Preview {
    GameView()
}
