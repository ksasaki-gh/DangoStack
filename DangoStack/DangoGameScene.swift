//
//  DangoGameScene.swift
//  DangoStack
//

import SpriteKit

final class DangoGameScene: SKScene {
    private enum Appearance {
        static let backgroundColor = SKColor(
            red: 0.96,
            green: 0.84,
            blue: 0.72,
            alpha: 1.0
        )
    }

    override init(size: CGSize) {
        super.init(size: size)
        backgroundColor = Appearance.backgroundColor
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = Appearance.backgroundColor
    }
}
