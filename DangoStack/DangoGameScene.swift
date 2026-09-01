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
        static let dangoColor = SKColor(
            red: 0.96,
            green: 0.48,
            blue: 0.62,
            alpha: 1.0
        )
    }

    private enum Layout {
        static let skewerXPositionRatios: [CGFloat] = [0.25, 0.5, 0.75]
        static let skewerCenterYRatio: CGFloat = 0.23
        static let skewerWidthRatio: CGFloat = 0.025
        static let skewerHeightRatio: CGFloat = 0.30
    }

    private enum DangoParameters {
        static let diameter: CGFloat = 56
        static let horizontalSpeed: CGFloat = 140
        static let horizontalRangeRatios: ClosedRange<CGFloat> = 0.18...0.82
        static let fallingSpeed: CGFloat = 380

        static let spawnXRatio: CGFloat = 0.5
        static let spawnYRatio: CGFloat = 0.82
        static let respawnDelay: TimeInterval = 0.6
        static let maximumFrameDuration: TimeInterval = 1.0 / 15.0
    }

    private enum LandingAnimationParameters {
        static let goodHorizontalOffset: CGFloat = 8
        static let stuckCenterYOffset: CGFloat = 0
        static let snapDuration: TimeInterval = 0.08

        static let squashScaleX: CGFloat = 1.10
        static let squashScaleY: CGFloat = 0.85
        static let squashDuration: TimeInterval = 0.05
        static let restoreDuration: TimeInterval = 0.08
    }

    private enum DangoState {
        case movingHorizontally
        case falling
        case stuck
    }

    private var skewers: [SKShapeNode] = []
    private var dango: SKShapeNode?
    private var dangoState = DangoState.movingHorizontally
    private var horizontalDirection: CGFloat = 1
    private var previousUpdateTime: TimeInterval?
    private var respawnTimeRemaining: TimeInterval = 0
    private var hasJudgedCurrentDango = false

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
        layoutDangoForCurrentSceneSize()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard dango != nil else { return }

        if case .movingHorizontally = dangoState {
            dangoState = .falling
        }
    }

    override func update(_ currentTime: TimeInterval) {
        defer { previousUpdateTime = currentTime }

        guard let previousUpdateTime else { return }

        let frameDuration = min(
            currentTime - previousUpdateTime,
            DangoParameters.maximumFrameDuration
        )

        if let dango {
            update(dango: dango, frameDuration: CGFloat(frameDuration))
        } else {
            updateRespawnTimer(frameDuration: frameDuration)
        }
    }

    private func configureScene() {
        backgroundColor = Appearance.backgroundColor
        addSkewers()
        layoutSkewers()
        spawnDango()
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

    private func spawnDango() {
        let radius = DangoParameters.diameter / 2
        let newDango = SKShapeNode(circleOfRadius: radius)
        newDango.fillColor = Appearance.dangoColor
        newDango.strokeColor = Appearance.dangoColor
        newDango.position = CGPoint(
            x: size.width * DangoParameters.spawnXRatio,
            y: size.height * DangoParameters.spawnYRatio
        )
        newDango.zPosition = 1
        addChild(newDango)

        dango = newDango
        dangoState = .movingHorizontally
        horizontalDirection = 1
        hasJudgedCurrentDango = false
    }

    private func layoutDangoForCurrentSceneSize() {
        guard let dango else { return }

        let horizontalRange = dangoHorizontalRange
        dango.position.x = min(
            max(dango.position.x, horizontalRange.lowerBound),
            horizontalRange.upperBound
        )

        if case .movingHorizontally = dangoState {
            dango.position.y = size.height * DangoParameters.spawnYRatio
        }
    }

    private func update(dango: SKShapeNode, frameDuration: CGFloat) {
        switch dangoState {
        case .movingHorizontally:
            updateHorizontalMovement(of: dango, frameDuration: frameDuration)
        case .falling:
            updateFallingMovement(of: dango, frameDuration: frameDuration)
        case .stuck:
            break
        }
    }

    private func updateHorizontalMovement(of dango: SKShapeNode, frameDuration: CGFloat) {
        let horizontalRange = dangoHorizontalRange
        var nextX = dango.position.x
            + DangoParameters.horizontalSpeed * horizontalDirection * frameDuration

        if nextX >= horizontalRange.upperBound {
            nextX = horizontalRange.upperBound
            horizontalDirection = -1
        } else if nextX <= horizontalRange.lowerBound {
            nextX = horizontalRange.lowerBound
            horizontalDirection = 1
        }

        dango.position.x = nextX
    }

    private func updateFallingMovement(of dango: SKShapeNode, frameDuration: CGFloat) {
        dango.position.y -= DangoParameters.fallingSpeed * frameDuration
        judgeDangoIfNeeded(dango)

        let radius = DangoParameters.diameter / 2
        guard dango.position.y + radius < 0 else { return }

        dango.removeFromParent()
        self.dango = nil
        respawnTimeRemaining = DangoParameters.respawnDelay
    }

    private func updateRespawnTimer(frameDuration: TimeInterval) {
        respawnTimeRemaining -= frameDuration

        if respawnTimeRemaining <= 0 {
            spawnDango()
        }
    }

    private func judgeDangoIfNeeded(_ dango: SKShapeNode) {
        guard !hasJudgedCurrentDango,
              dango.position.y <= dangoJudgementY else {
            return
        }

        hasJudgedCurrentDango = true

        let skewerCenterXs = Layout.skewerXPositionRatios.map { size.width * $0 }
        let result = HitJudge.judge(
            dangoX: dango.position.x,
            dangoDiameter: DangoParameters.diameter,
            skewerCenterXs: skewerCenterXs
        )

        print("[HitJudge] \(debugText(for: result))")

        if case .miss = result {
            return
        }

        guard let targetSkewerX = HitJudge.nearestSkewerCenterX(
            dangoX: dango.position.x,
            skewerCenterXs: skewerCenterXs
        ) else { return }

        stick(dango, result: result, targetSkewerX: targetSkewerX)
    }

    private func stick(
        _ dango: SKShapeNode,
        result: HitResult,
        targetSkewerX: CGFloat
    ) {
        dangoState = .stuck

        let targetPosition = CGPoint(
            x: snappedX(for: result, skewerCenterX: targetSkewerX),
            y: skewerTopY + LandingAnimationParameters.stuckCenterYOffset
        )
        let snapAction = SKAction.move(
            to: targetPosition,
            duration: LandingAnimationParameters.snapDuration
        )
        snapAction.timingMode = .easeOut

        let squashAction = SKAction.group([
            SKAction.scaleX(
                to: LandingAnimationParameters.squashScaleX,
                duration: LandingAnimationParameters.squashDuration
            ),
            SKAction.scaleY(
                to: LandingAnimationParameters.squashScaleY,
                duration: LandingAnimationParameters.squashDuration
            ),
        ])
        squashAction.timingMode = .easeOut

        let restoreAction = SKAction.group([
            SKAction.scaleX(
                to: 1,
                duration: LandingAnimationParameters.restoreDuration
            ),
            SKAction.scaleY(
                to: 1,
                duration: LandingAnimationParameters.restoreDuration
            ),
        ])
        restoreAction.timingMode = .easeOut

        let puniAction = SKAction.sequence([squashAction, restoreAction])
        dango.run(SKAction.group([snapAction, puniAction]))
    }

    private func snappedX(for result: HitResult, skewerCenterX: CGFloat) -> CGFloat {
        switch result {
        case .perfect:
            return skewerCenterX
        case .goodLeft:
            return skewerCenterX - LandingAnimationParameters.goodHorizontalOffset
        case .goodRight:
            return skewerCenterX + LandingAnimationParameters.goodHorizontalOffset
        case .miss:
            return skewerCenterX
        }
    }

    private func debugText(for result: HitResult) -> String {
        switch result {
        case .perfect:
            return "PERFECT"
        case .goodLeft:
            return "GOOD LEFT"
        case .goodRight:
            return "GOOD RIGHT"
        case .miss:
            return "MISS"
        }
    }

    private var dangoHorizontalRange: ClosedRange<CGFloat> {
        let range = DangoParameters.horizontalRangeRatios
        return (size.width * range.lowerBound)...(size.width * range.upperBound)
    }

    private var dangoJudgementY: CGFloat {
        return skewerTopY + DangoParameters.diameter / 2
    }

    private var skewerTopY: CGFloat {
        size.height * (Layout.skewerCenterYRatio + Layout.skewerHeightRatio / 2)
    }
}
