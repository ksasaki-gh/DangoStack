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
        static let skewerColor = SKColor(
            red: 0.45,
            green: 0.27,
            blue: 0.12,
            alpha: 1.0
        )
    }

    private enum Layout {
        static let skewerXPositionRatios: [CGFloat] = [0.25, 0.5, 0.75]
        static let skewerCenterYRatio: CGFloat = 0.23
        static let skewerWidthRatio: CGFloat = 0.025
        static let skewerHeightRatio: CGFloat = 0.30
    }

    private var skewers: [SKShapeNode] = []

    override init(size: CGSize) {
        super.init(size: size)
        configureScene()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureScene()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        layoutSkewers()
    }

    private func configureScene() {
        backgroundColor = Appearance.backgroundColor
        addSkewers()
        layoutSkewers()
    }

    private func addSkewers() {
        skewers = Layout.skewerXPositionRatios.map { _ in
            let skewer = SKShapeNode()
            skewer.fillColor = Appearance.skewerColor
            skewer.strokeColor = Appearance.skewerColor
            addChild(skewer)
            return skewer
        }
    }

    private func layoutSkewers() {
        let skewerSize = CGSize(
            width: size.width * Layout.skewerWidthRatio,
            height: size.height * Layout.skewerHeightRatio
        )
        let skewerRect = CGRect(
            x: -skewerSize.width / 2,
            y: -skewerSize.height / 2,
            width: skewerSize.width,
            height: skewerSize.height
        )
        let cornerRadius = skewerSize.width / 2

        for (skewer, xPositionRatio) in zip(skewers, Layout.skewerXPositionRatios) {
            skewer.path = CGPath(
                roundedRect: skewerRect,
                cornerWidth: cornerRadius,
                cornerHeight: cornerRadius,
                transform: nil
            )
            skewer.position = CGPoint(
                x: size.width * xPositionRatio,
                y: size.height * Layout.skewerCenterYRatio
            )
        }
    }
}
