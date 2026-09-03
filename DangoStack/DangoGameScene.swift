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

        static let underlyingSquashScaleY: CGFloat = 0.94
        static let underlyingSquashDuration: TimeInterval = 0.05
        static let underlyingRestoreDuration: TimeInterval = 0.08
    }

    private enum StackLayoutParameters {
        static let dangoVerticalSpacing: CGFloat = 52
    }

    private enum WrongAnimationParameters {
        static let horizontalKickDistance: CGFloat = 22
        static let upwardKickDistance: CGFloat = 18
        static let kickDuration: TimeInterval = 0.10
        static let fallDuration: TimeInterval = 0.42

        static let labelFontSize: CGFloat = 16
        static let labelYOffset: CGFloat = 42
        static let labelRiseDistance: CGFloat = 16
        static let labelDisplayDuration: TimeInterval = 0.45
    }

    private enum NextDisplayParameters {
        static let centerXRatio: CGFloat = 0.87
        static let labelYRatio: CGFloat = 0.92
        static let previewDiameter: CGFloat = 28
        static let previewYOffset: CGFloat = 34
        static let labelFontSize: CGFloat = 16
        static let previewLineWidth: CGFloat = 1.5
    }

    private enum StageClearDisplayParameters {
        static let centerYRatio: CGFloat = 0.63
        static let clearLabelFontSize: CGFloat = 38
        static let retryLabelFontSize: CGFloat = 17
        static let retryLabelYOffset: CGFloat = -52
        static let revealDelay: TimeInterval = 0.35
        static let revealDuration: TimeInterval = 0.20
        static let initialScale: CGFloat = 0.92
    }

    private enum GameState {
        case playing
        case stageCleared
    }

    private enum DangoState {
        case movingHorizontally
        case falling
        case wrong
        case stuck
    }

    private enum FailureKind: String {
        case miss = "MISS"
        case wrong = "WRONG"
    }

    private var skewers: [SKShapeNode] = []
    private var skewerStates: [SkewerState] = []
    private var dango: SKShapeNode?
    private var nextLabelNode: SKLabelNode?
    private var nextPreviewNode: SKShapeNode?
    private var stageClearNode: SKNode?
    private var dangoGenerator = DangoGenerator()
    private var currentDangoColor: DangoColor?
    private var nextDangoColor: DangoColor?
    private var gameState = GameState.playing
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
        layoutNextDisplay()
        layoutDangoForCurrentSceneSize()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if case .stageCleared = gameState {
            resetGame()
            return
        }

        guard dango != nil else { return }

        if case .movingHorizontally = dangoState {
            dangoState = .falling
        }
    }

    override func update(_ currentTime: TimeInterval) {
        guard case .playing = gameState else { return }

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
        resetGame()
    }

    private func resetGame() {
        removeAllActions()
        children.forEach { $0.removeAllActions() }
        removeAllChildren()

        skewers.removeAll()
        skewerStates = Layout.skewerXPositionRatios.map {
            SkewerState(xPositionRatio: $0)
        }
        dango = nil
        nextLabelNode = nil
        nextPreviewNode = nil
        stageClearNode = nil

        dangoGenerator = DangoGenerator()
        currentDangoColor = nil
        nextDangoColor = nil
        gameState = .playing
        dangoState = .movingHorizontally
        horizontalDirection = 1
        previousUpdateTime = nil
        respawnTimeRemaining = 0
        hasJudgedCurrentDango = false

        prepareInitialDangoColors()
        addSkewers()
        addNextDisplay()
        layoutSkewers()
        layoutNextDisplay()
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

    private func addNextDisplay() {
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = "NEXT"
        label.fontSize = NextDisplayParameters.labelFontSize
        label.fontColor = Appearance.skewerColor
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.zPosition = 10
        addChild(label)
        nextLabelNode = label

        let previewRadius = NextDisplayParameters.previewDiameter / 2
        let preview = SKShapeNode(circleOfRadius: previewRadius)
        preview.strokeColor = Appearance.skewerColor
        preview.lineWidth = NextDisplayParameters.previewLineWidth
        preview.zPosition = 10
        addChild(preview)
        nextPreviewNode = preview

        updateNextDisplayColor()
    }

    private func layoutNextDisplay() {
        let centerX = size.width * NextDisplayParameters.centerXRatio
        let labelY = size.height * NextDisplayParameters.labelYRatio
        nextLabelNode?.position = CGPoint(x: centerX, y: labelY)
        nextPreviewNode?.position = CGPoint(
            x: centerX,
            y: labelY - NextDisplayParameters.previewYOffset
        )
    }

    private func spawnDango() {
        guard let currentDangoColor else { return }

        let radius = DangoParameters.diameter / 2
        let newDango = SKShapeNode(circleOfRadius: radius)
        newDango.fillColor = spriteColor(for: currentDangoColor)
        newDango.strokeColor = spriteColor(for: currentDangoColor)
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
        case .wrong:
            break
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
        finishFailedDango(.miss)
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

        let skewerCenterXs = skewerStates.map { size.width * $0.xPositionRatio }
        let result = HitJudge.judge(
            dangoX: dango.position.x,
            dangoDiameter: DangoParameters.diameter,
            skewerCenterXs: skewerCenterXs
        )

        print("[HitJudge] \(debugText(for: result))")

        if case .miss = result {
            return
        }

        guard let targetSkewerIndex = HitJudge.nearestSkewerIndex(
            dangoX: dango.position.x,
            skewerCenterXs: skewerCenterXs
        ) else { return }

        guard let dangoColor = currentDangoColor else { return }
        guard let requiredColor = skewerStates[targetSkewerIndex].nextRequiredColor else {
            print("[Landing] WRONG: skewer is full")
            handleWrongLanding(
                dango,
                targetSkewerX: skewerCenterXs[targetSkewerIndex]
            )
            return
        }

        guard dangoColor == requiredColor else {
            print(
                "[Landing] WRONG: \(dangoColor.rawValue), "
                    + "required: \(requiredColor.rawValue)"
            )
            handleWrongLanding(
                dango,
                targetSkewerX: skewerCenterXs[targetSkewerIndex]
            )
            return
        }

        stick(
            dango,
            result: result,
            targetSkewerIndex: targetSkewerIndex,
            targetSkewerX: skewerCenterXs[targetSkewerIndex]
        )
    }

    private func handleWrongLanding(_ dango: SKShapeNode, targetSkewerX: CGFloat) {
        dangoState = .wrong
        showWrongLabel(at: dango.position)

        let kickDirection: CGFloat = dango.position.x < targetSkewerX ? -1 : 1
        let kickAction = SKAction.moveBy(
            x: WrongAnimationParameters.horizontalKickDistance * kickDirection,
            y: WrongAnimationParameters.upwardKickDistance,
            duration: WrongAnimationParameters.kickDuration
        )
        kickAction.timingMode = .easeOut

        let fallAction = SKAction.moveTo(
            y: -DangoParameters.diameter,
            duration: WrongAnimationParameters.fallDuration
        )
        fallAction.timingMode = .easeIn

        dango.run(SKAction.sequence([kickAction, fallAction])) { [weak self, weak dango] in
            guard let self, let dango, self.dango === dango else { return }
            dango.removeFromParent()
            self.dango = nil
            self.finishFailedDango(.wrong)
        }
    }

    private func showWrongLabel(at position: CGPoint) {
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = "WRONG"
        label.fontSize = WrongAnimationParameters.labelFontSize
        label.fontColor = SKColor(red: 0.72, green: 0.20, blue: 0.18, alpha: 1.0)
        label.verticalAlignmentMode = .center
        label.position = CGPoint(
            x: position.x,
            y: position.y + WrongAnimationParameters.labelYOffset
        )
        label.zPosition = 10
        addChild(label)

        let fadeAction = SKAction.fadeOut(
            withDuration: WrongAnimationParameters.labelDisplayDuration
        )
        let riseAction = SKAction.moveBy(
            x: 0,
            y: WrongAnimationParameters.labelRiseDistance,
            duration: WrongAnimationParameters.labelDisplayDuration
        )
        label.run(SKAction.sequence([
            SKAction.group([fadeAction, riseAction]),
            SKAction.removeFromParent(),
        ]))
    }

    private func stick(
        _ dango: SKShapeNode,
        result: HitResult,
        targetSkewerIndex: Int,
        targetSkewerX: CGFloat
    ) {
        let stackLevel = skewerStates[targetSkewerIndex].dangoCount
        let underlyingDango = skewerStates[targetSkewerIndex].dangoNodes.last
        guard skewerStates[targetSkewerIndex].addDangoNode(dango) else { return }

        dangoState = .stuck

        let targetPosition = CGPoint(
            x: snappedX(for: result, skewerCenterX: targetSkewerX),
            y: stackedDangoY(for: stackLevel)
                + LandingAnimationParameters.stuckCenterYOffset
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
        let landingAction = SKAction.group([snapAction, puniAction])

        if let underlyingDango {
            animateUnderlyingDango(underlyingDango)
        }

        dango.run(landingAction) { [weak self, weak dango] in
            guard let self, let dango, self.dango === dango else { return }
            self.dango = nil

            if self.isStageClear {
                self.showStageClear()
            } else {
                self.advanceAfterSuccessfulDango()
            }
        }
    }

    private func showStageClear() {
        guard stageClearNode == nil else { return }

        gameState = .stageCleared
        nextLabelNode?.isHidden = true
        nextPreviewNode?.isHidden = true

        let container = SKNode()
        container.position = CGPoint(
            x: size.width / 2,
            y: size.height * StageClearDisplayParameters.centerYRatio
        )
        container.zPosition = 20
        container.alpha = 0
        container.setScale(StageClearDisplayParameters.initialScale)
        addChild(container)
        stageClearNode = container

        let clearLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        clearLabel.text = "STAGE CLEAR!"
        clearLabel.fontSize = StageClearDisplayParameters.clearLabelFontSize
        clearLabel.fontColor = Appearance.skewerColor
        clearLabel.horizontalAlignmentMode = .center
        clearLabel.verticalAlignmentMode = .center
        container.addChild(clearLabel)

        let retryLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        retryLabel.text = "TAP TO RETRY"
        retryLabel.fontSize = StageClearDisplayParameters.retryLabelFontSize
        retryLabel.fontColor = Appearance.skewerColor
        retryLabel.horizontalAlignmentMode = .center
        retryLabel.verticalAlignmentMode = .center
        retryLabel.position.y = StageClearDisplayParameters.retryLabelYOffset
        container.addChild(retryLabel)

        let revealAction = SKAction.group([
            SKAction.fadeIn(withDuration: StageClearDisplayParameters.revealDuration),
            SKAction.scale(
                to: 1,
                duration: StageClearDisplayParameters.revealDuration
            ),
        ])
        revealAction.timingMode = .easeOut
        container.run(SKAction.sequence([
            SKAction.wait(forDuration: StageClearDisplayParameters.revealDelay),
            revealAction,
        ]))
    }

    private func animateUnderlyingDango(_ underlyingDango: SKShapeNode) {
        let squashAction = SKAction.scaleY(
            to: LandingAnimationParameters.underlyingSquashScaleY,
            duration: LandingAnimationParameters.underlyingSquashDuration
        )
        squashAction.timingMode = .easeOut

        let restoreAction = SKAction.scaleY(
            to: 1,
            duration: LandingAnimationParameters.underlyingRestoreDuration
        )
        restoreAction.timingMode = .easeOut

        underlyingDango.run(SKAction.sequence([squashAction, restoreAction]))
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

    private func stackedDangoY(for stackLevel: Int) -> CGFloat {
        let levelsBelowTop = SkewerState.maximumDangoCount - 1 - stackLevel
        return skewerTopY
            - CGFloat(levelsBelowTop) * StackLayoutParameters.dangoVerticalSpacing
    }

    private func spriteColor(for dangoColor: DangoColor) -> SKColor {
        switch dangoColor {
        case .green:
            return SKColor(red: 0.48, green: 0.72, blue: 0.40, alpha: 1.0)
        case .white:
            return SKColor(red: 0.98, green: 0.96, blue: 0.90, alpha: 1.0)
        case .pink:
            return Appearance.dangoColor
        }
    }

    private func prepareInitialDangoColors() {
        let requiredColors = skewerRequiredColors
        currentDangoColor = dangoGenerator.generateCurrentColor(
            requiredColors: requiredColors
        )

        guard let currentDangoColor else {
            nextDangoColor = nil
            return
        }

        nextDangoColor = dangoGenerator.generateSafeNextColor(
            currentColor: currentDangoColor,
            requiredColors: requiredColors
        )
    }

    private func advanceAfterSuccessfulDango() {
        let requiredColors = skewerRequiredColors
        currentDangoColor = nextDangoColor
            ?? dangoGenerator.generateCurrentColor(requiredColors: requiredColors)

        if let currentDangoColor {
            nextDangoColor = dangoGenerator.generateSafeNextColor(
                currentColor: currentDangoColor,
                requiredColors: requiredColors
            )
        } else {
            nextDangoColor = nil
        }

        updateNextDisplayColor()
        respawnTimeRemaining = DangoParameters.respawnDelay
    }

    private func finishFailedDango(_ failureKind: FailureKind) {
        print("[Failure] \(failureKind.rawValue)")
        respawnTimeRemaining = DangoParameters.respawnDelay
    }

    private func updateNextDisplayColor() {
        guard let nextDangoColor else {
            nextPreviewNode?.isHidden = true
            return
        }

        nextPreviewNode?.isHidden = false
        nextPreviewNode?.fillColor = spriteColor(for: nextDangoColor)
    }

    private var skewerRequiredColors: [DangoColor?] {
        skewerStates.map(\.nextRequiredColor)
    }

    private var isStageClear: Bool {
        skewerStates.count == Layout.skewerXPositionRatios.count
            && skewerStates.allSatisfy(\.isFull)
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
