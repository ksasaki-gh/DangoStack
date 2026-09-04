//
//  DangoGameScene.swift
//  DangoStack
//

import SpriteKit
import UIKit

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
        static let perfectFeedbackColor = SKColor(
            red: 0.84,
            green: 0.35,
            blue: 0.16,
            alpha: 1.0
        )
        static let missFeedbackColor = SKColor(
            red: 0.43,
            green: 0.38,
            blue: 0.34,
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
        static let tapSquashScaleX: CGFloat = 1.16
        static let tapSquashScaleY: CGFloat = 0.82
        static let tapSquashDuration: TimeInterval = 0.08
        static let initialFallSpeed: CGFloat = 0
        static let fallAcceleration: CGFloat = 1350
        static let maximumFallSpeed: CGFloat = 975

        static let spawnXRatio: CGFloat = 0.5
        static let spawnYRatio: CGFloat = 0.82
        static let respawnDelay: TimeInterval = 0.6
        static let maximumFrameDuration: TimeInterval = 1.0 / 15.0
    }

    private enum LandingAnimationParameters {
        static let goodHorizontalOffset: CGFloat = 8
        static let stuckCenterYOffset: CGFloat = 0
        static let snapDuration: TimeInterval = 0.08

        static let goodSquashScaleX: CGFloat = 1.10
        static let goodSquashScaleY: CGFloat = 0.86
        static let perfectSquashScaleX: CGFloat = 1.12
        static let perfectSquashScaleY: CGFloat = 0.82
        static let squashDuration: TimeInterval = 0.06
        static let overshootScaleX: CGFloat = 0.98
        static let overshootScaleY: CGFloat = 1.06
        static let overshootDuration: TimeInterval = 0.06
        static let restoreDuration: TimeInterval = 0.07
        static let impactOvershootDistancePerfect: CGFloat = 5
        static let impactOvershootDistanceGood: CGFloat = 3
        static let impactOvershootDuration: TimeInterval = 0.06
        static let impactReturnDuration: TimeInterval = 0.06

        static let underlyingSquashScaleY: CGFloat = 0.94
        static let underlyingSinkAmount: CGFloat = 3
        static let underlyingSquashDuration: TimeInterval = 0.05
        static let underlyingRestoreDuration: TimeInterval = 0.08
    }

    private enum StackLayoutParameters {
        static let dangoVerticalSpacing: CGFloat = 52
    }

    private enum WrongAnimationParameters {
        static let contactPauseDuration: TimeInterval = 0.05
        static let horizontalKickDistance: CGFloat = 22
        static let upwardKickDistance: CGFloat = 18
        static let kickDuration: TimeInterval = 0.10
        static let fallDuration: TimeInterval = 0.42
    }

    private enum JudgeFeedbackParameters {
        static let labelYOffset: CGFloat = 78
        static let missLabelYOffset: CGFloat = 58
        static let perfectFontSize: CGFloat = 24
        static let standardFontSize: CGFloat = 20
        static let perfectInitialScale: CGFloat = 0.70
        static let standardInitialScale: CGFloat = 0.82
        static let perfectPopScale: CGFloat = 1.20
        static let goodPopScale: CGFloat = 1.10
        static let failurePopScale: CGFloat = 1.07
        static let popDuration: TimeInterval = 0.08
        static let settleDuration: TimeInterval = 0.07
        static let fadeDuration: TimeInterval = 0.32
        static let riseDistance: CGFloat = 18
        static let wrongShakeAmount: CGFloat = 3
        static let wrongShakeStepDuration: TimeInterval = 0.04

        static let perfectRingInitialScale: CGFloat = 0.70
        static let perfectRingFinalScale: CGFloat = 1.35
        static let perfectRingDuration: TimeInterval = 0.20
        static let perfectRingLineWidth: CGFloat = 2
    }

    private enum HapticParameters {
        static let perfectIntensity: CGFloat = 0.85
        static let goodIntensity: CGFloat = 0.55
        static let wrongIntensity: CGFloat = 0.40
        static let missIntensity: CGFloat = 0.30
    }

    private enum NextDisplayParameters {
        static let centerXRatio: CGFloat = 0.87
        static let labelYRatio: CGFloat = 0.92
        static let previewDiameter: CGFloat = 28
        static let previewYOffset: CGFloat = 34
        static let labelFontSize: CGFloat = 16
        static let previewLineWidth: CGFloat = 1.5
    }

    private enum StageResultDisplayParameters {
        static let centerYRatio: CGFloat = 0.68
        static let titleLabelFontSize: CGFloat = 38
        static let starsFontSize: CGFloat = 29
        static let starsYOffset: CGFloat = -50
        static let perfectClearFontSize: CGFloat = 21
        static let perfectClearYOffset: CGFloat = -89
        static let perfectClearInitialScale: CGFloat = 0.88
        static let perfectClearAnimationDelay: TimeInterval = 0.52
        static let perfectClearAnimationDuration: TimeInterval = 0.14
        static let perfectClearAnimationScale: CGFloat = 1.10
        static let detailLabelFontSize: CGFloat = 15
        static let detailFirstYOffset: CGFloat = -92
        static let perfectClearDetailFirstYOffset: CGFloat = -127
        static let detailLineSpacing: CGFloat = 22
        static let retryLabelFontSize: CGFloat = 17
        static let retryLabelYOffset: CGFloat = -52
        static let evaluatedRetryLabelYOffset: CGFloat = -202
        static let perfectClearRetryLabelYOffset: CGFloat = -237
        static let revealDelay: TimeInterval = 0.35
        static let revealDuration: TimeInterval = 0.20
        static let initialScale: CGFloat = 0.92
    }

    private enum FailureParameters {
        static let maximumCount = 3
        static let indicatorRadius: CGFloat = 6
        static let indicatorSpacing: CGFloat = 24
        static let indicatorCenterYRatio: CGFloat = 0.045
        static let indicatorLineWidth: CGFloat = 2
        static let failedColor = SKColor(
            red: 0.72,
            green: 0.20,
            blue: 0.18,
            alpha: 1.0
        )
    }

    private enum GameState {
        case playing
        case stageCleared
        case stageFailed
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

    private enum JudgeFeedbackKind {
        case perfect
        case good
        case wrong
        case miss
    }

    private var skewers: [SKShapeNode] = []
    private var skewerStates: [SkewerState] = []
    private var dango: SKShapeNode?
    private var nextLabelNode: SKLabelNode?
    private var nextPreviewNode: SKShapeNode?
    private var failureIndicatorNodes: [SKShapeNode] = []
    private var stageResultNode: SKNode?
    private var dangoGenerator = DangoGenerator()
    private var currentDangoColor: DangoColor?
    private var nextDangoColor: DangoColor?
    private var gameState = GameState.playing
    private var dangoState = DangoState.movingHorizontally
    private var horizontalDirection: CGFloat = 1
    private var currentFallSpeed: CGFloat = 0
    private var previousUpdateTime: TimeInterval?
    private var respawnTimeRemaining: TimeInterval = 0
    private var hasJudgedCurrentDango = false
    private var missCount = 0
    private var wrongCount = 0
    private var perfectCount = 0
    private var goodCount = 0
    private(set) var stageResult: StageResult?

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
        layoutFailureHUD()
        layoutDangoForCurrentSceneSize()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if case .stageCleared = gameState {
            resetGame()
            return
        }

        if case .stageFailed = gameState {
            resetGame()
            return
        }

        guard let dango else { return }

        if case .movingHorizontally = dangoState {
            beginFalling(dango)
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
        failureIndicatorNodes.removeAll()
        stageResultNode = nil

        dangoGenerator = DangoGenerator()
        currentDangoColor = nil
        nextDangoColor = nil
        gameState = .playing
        dangoState = .movingHorizontally
        horizontalDirection = 1
        currentFallSpeed = 0
        previousUpdateTime = nil
        respawnTimeRemaining = 0
        hasJudgedCurrentDango = false
        missCount = 0
        wrongCount = 0
        perfectCount = 0
        goodCount = 0
        stageResult = nil

        prepareInitialDangoColors()
        addSkewers()
        addNextDisplay()
        addFailureHUD()
        layoutSkewers()
        layoutNextDisplay()
        layoutFailureHUD()
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

    private func addFailureHUD() {
        failureIndicatorNodes = (0..<FailureParameters.maximumCount).map { _ in
            let indicator = SKShapeNode(
                circleOfRadius: FailureParameters.indicatorRadius
            )
            indicator.strokeColor = Appearance.skewerColor
            indicator.lineWidth = FailureParameters.indicatorLineWidth
            indicator.zPosition = 10
            addChild(indicator)
            return indicator
        }

        updateFailureHUD()
    }

    private func layoutFailureHUD() {
        let indicatorCount = CGFloat(failureIndicatorNodes.count)
        let totalWidth = FailureParameters.indicatorSpacing * (indicatorCount - 1)
        let startX = (size.width - totalWidth) / 2
        let centerY = size.height * FailureParameters.indicatorCenterYRatio

        for (index, indicator) in failureIndicatorNodes.enumerated() {
            indicator.position = CGPoint(
                x: startX + CGFloat(index) * FailureParameters.indicatorSpacing,
                y: centerY
            )
        }
    }

    private func updateFailureHUD() {
        for (index, indicator) in failureIndicatorNodes.enumerated() {
            let isUsed = index < totalFailureCount
            indicator.fillColor = isUsed ? FailureParameters.failedColor : .clear
            indicator.strokeColor = isUsed
                ? FailureParameters.failedColor
                : Appearance.skewerColor
        }
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
        currentFallSpeed = 0
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

    private func beginFalling(_ dango: SKShapeNode) {
        let lockedXPosition = dango.position.x
        dangoState = .falling
        currentFallSpeed = DangoParameters.initialFallSpeed
        dango.position.x = lockedXPosition

        let squashAction = SKAction.group([
            SKAction.scaleX(
                to: DangoParameters.tapSquashScaleX,
                duration: DangoParameters.tapSquashDuration
            ),
            SKAction.scaleY(
                to: DangoParameters.tapSquashScaleY,
                duration: DangoParameters.tapSquashDuration
            ),
        ])
        squashAction.timingMode = .easeOut

        let restoreAction = SKAction.group([
            SKAction.scaleX(
                to: 1,
                duration: DangoParameters.tapSquashDuration
            ),
            SKAction.scaleY(
                to: 1,
                duration: DangoParameters.tapSquashDuration
            ),
        ])
        restoreAction.timingMode = .easeInEaseOut

        dango.run(
            SKAction.sequence([squashAction, restoreAction]),
            withKey: "tapSquash"
        )
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
        let previousY = dango.position.y
        let previousFallSpeed = currentFallSpeed
        currentFallSpeed = min(
            DangoParameters.maximumFallSpeed,
            currentFallSpeed + DangoParameters.fallAcceleration * frameDuration
        )
        let fallDistance = (previousFallSpeed + currentFallSpeed)
            * 0.5
            * frameDuration
        let nextY = previousY - fallDistance

        let crossedJudgementLine = !hasJudgedCurrentDango
            && previousY > dangoJudgementY
            && nextY <= dangoJudgementY

        if crossedJudgementLine {
            dango.position.y = dangoJudgementY
            judgeDangoIfNeeded(dango)

            if case .falling = dangoState {
                dango.position.y = nextY
            }
        } else {
            dango.position.y = nextY
            judgeDangoIfNeeded(dango)
        }

        guard case .falling = dangoState else { return }

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
            showJudgeFeedback(
                .miss,
                at: CGPoint(
                    x: size.width / 2,
                    y: dangoJudgementY + JudgeFeedbackParameters.missLabelYOffset
                )
            )
            triggerHaptic(for: .miss)
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
        showJudgeFeedback(
            .wrong,
            at: judgeFeedbackPosition(targetSkewerX: targetSkewerX)
        )
        triggerHaptic(for: .wrong)

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

        dango.run(SKAction.sequence([
            SKAction.wait(forDuration: WrongAnimationParameters.contactPauseDuration),
            kickAction,
            fallAction,
        ])) { [weak self, weak dango] in
            guard let self, let dango, self.dango === dango else { return }
            dango.removeFromParent()
            self.dango = nil
            self.finishFailedDango(.wrong)
        }
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
        recordSuccessfulLanding(result)

        let isPerfect: Bool
        let feedbackKind: JudgeFeedbackKind
        if case .perfect = result {
            isPerfect = true
            feedbackKind = .perfect
        } else {
            isPerfect = false
            feedbackKind = .good
        }

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

        let squashScaleX = isPerfect
            ? LandingAnimationParameters.perfectSquashScaleX
            : LandingAnimationParameters.goodSquashScaleX
        let squashScaleY = isPerfect
            ? LandingAnimationParameters.perfectSquashScaleY
            : LandingAnimationParameters.goodSquashScaleY
        let squashAction = SKAction.group([
            SKAction.scaleX(
                to: squashScaleX,
                duration: LandingAnimationParameters.squashDuration
            ),
            SKAction.scaleY(
                to: squashScaleY,
                duration: LandingAnimationParameters.squashDuration
            ),
        ])
        squashAction.timingMode = .easeOut

        let overshootAction = SKAction.group([
            SKAction.scaleX(
                to: LandingAnimationParameters.overshootScaleX,
                duration: LandingAnimationParameters.overshootDuration
            ),
            SKAction.scaleY(
                to: LandingAnimationParameters.overshootScaleY,
                duration: LandingAnimationParameters.overshootDuration
            ),
        ])
        overshootAction.timingMode = .easeInEaseOut

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
        restoreAction.timingMode = .easeInEaseOut

        let impactAction = SKAction.run { [weak self, weak underlyingDango] in
            guard let self else { return }
            self.showJudgeFeedback(
                feedbackKind,
                at: self.judgeFeedbackPosition(targetSkewerX: targetSkewerX)
            )
            self.triggerHaptic(for: feedbackKind)

            if let underlyingDango {
                self.animateUnderlyingDango(underlyingDango)
            }

            if isPerfect {
                self.showPerfectRing(at: targetPosition)
            }
        }

        let impactOvershootDistance = isPerfect
            ? LandingAnimationParameters.impactOvershootDistancePerfect
            : LandingAnimationParameters.impactOvershootDistanceGood
        let sinkAction = SKAction.moveTo(
            y: targetPosition.y - impactOvershootDistance,
            duration: LandingAnimationParameters.impactOvershootDuration
        )
        sinkAction.timingMode = .easeOut

        let returnAction = SKAction.moveTo(
            y: targetPosition.y,
            duration: LandingAnimationParameters.impactReturnDuration
        )
        returnAction.timingMode = .easeInEaseOut

        let squashAndSinkAction = SKAction.group([squashAction, sinkAction])
        let overshootAndReturnAction = SKAction.group([
            overshootAction,
            returnAction,
        ])
        let puniAction = SKAction.sequence([
            squashAndSinkAction,
            overshootAndReturnAction,
            restoreAction,
        ])
        let landingAction = SKAction.sequence([
            snapAction,
            impactAction,
            puniAction,
        ])

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
        gameState = .stageCleared
        let result = StageResult(
            isStageClear: true,
            perfectCount: perfectCount,
            goodCount: goodCount,
            missCount: missCount,
            wrongCount: wrongCount
        )
        stageResult = result
        showStageResult(
            title: "STAGE CLEAR!",
            titleColor: Appearance.skewerColor,
            evaluation: result
        )
    }

    private func showStageFailed() {
        gameState = .stageFailed
        showStageResult(title: "STAGE FAILED", titleColor: FailureParameters.failedColor)
    }

    private func showStageResult(
        title: String,
        titleColor: SKColor,
        evaluation: StageResult? = nil
    ) {
        guard stageResultNode == nil else { return }

        nextLabelNode?.isHidden = true
        nextPreviewNode?.isHidden = true

        let container = SKNode()
        container.position = CGPoint(
            x: size.width / 2,
            y: size.height * StageResultDisplayParameters.centerYRatio
        )
        container.zPosition = 20
        container.alpha = 0
        container.setScale(StageResultDisplayParameters.initialScale)
        addChild(container)
        stageResultNode = container

        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleLabel.text = title
        titleLabel.fontSize = StageResultDisplayParameters.titleLabelFontSize
        titleLabel.fontColor = titleColor
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.verticalAlignmentMode = .center
        container.addChild(titleLabel)

        if let evaluation {
            addEvaluationDisplay(evaluation, to: container)
        }

        let retryLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        retryLabel.text = "TAP TO RETRY"
        retryLabel.fontSize = StageResultDisplayParameters.retryLabelFontSize
        retryLabel.fontColor = Appearance.skewerColor
        retryLabel.horizontalAlignmentMode = .center
        retryLabel.verticalAlignmentMode = .center
        if let evaluation {
            retryLabel.position.y = evaluation.isPerfectClear
                ? StageResultDisplayParameters.perfectClearRetryLabelYOffset
                : StageResultDisplayParameters.evaluatedRetryLabelYOffset
        } else {
            retryLabel.position.y = StageResultDisplayParameters.retryLabelYOffset
        }
        container.addChild(retryLabel)

        let revealAction = SKAction.group([
            SKAction.fadeIn(withDuration: StageResultDisplayParameters.revealDuration),
            SKAction.scale(
                to: 1,
                duration: StageResultDisplayParameters.revealDuration
            ),
        ])
        revealAction.timingMode = .easeOut
        container.run(SKAction.sequence([
            SKAction.wait(forDuration: StageResultDisplayParameters.revealDelay),
            revealAction,
        ]))
    }

    private func addEvaluationDisplay(
        _ result: StageResult,
        to container: SKNode
    ) {
        let starsLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        starsLabel.text = result.starsText
        starsLabel.fontSize = StageResultDisplayParameters.starsFontSize
        starsLabel.fontColor = Appearance.skewerColor
        starsLabel.horizontalAlignmentMode = .center
        starsLabel.verticalAlignmentMode = .center
        starsLabel.position.y = StageResultDisplayParameters.starsYOffset
        container.addChild(starsLabel)

        if result.isPerfectClear {
            addPerfectClearDisplay(to: container)
        }

        let detailLines = [
            "PERFECT \(result.perfectCount)",
            "GOOD \(result.goodCount)",
            "MISS \(result.missCount)",
            "WRONG \(result.wrongCount)",
        ]
        let detailFirstYOffset = result.isPerfectClear
            ? StageResultDisplayParameters.perfectClearDetailFirstYOffset
            : StageResultDisplayParameters.detailFirstYOffset

        for (index, text) in detailLines.enumerated() {
            let detailLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
            detailLabel.text = text
            detailLabel.fontSize = StageResultDisplayParameters.detailLabelFontSize
            detailLabel.fontColor = Appearance.skewerColor
            detailLabel.horizontalAlignmentMode = .center
            detailLabel.verticalAlignmentMode = .center
            detailLabel.position.y = detailFirstYOffset
                - CGFloat(index) * StageResultDisplayParameters.detailLineSpacing
            container.addChild(detailLabel)
        }
    }

    private func addPerfectClearDisplay(to container: SKNode) {
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = "PERFECT CLEAR!"
        label.fontSize = StageResultDisplayParameters.perfectClearFontSize
        label.fontColor = Appearance.skewerColor
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.position.y = StageResultDisplayParameters.perfectClearYOffset
        label.setScale(StageResultDisplayParameters.perfectClearInitialScale)
        container.addChild(label)

        let growAction = SKAction.scale(
            to: StageResultDisplayParameters.perfectClearAnimationScale,
            duration: StageResultDisplayParameters.perfectClearAnimationDuration
        )
        growAction.timingMode = .easeOut

        let restoreAction = SKAction.scale(
            to: 1,
            duration: StageResultDisplayParameters.perfectClearAnimationDuration
        )
        restoreAction.timingMode = .easeInEaseOut

        label.run(SKAction.sequence([
            SKAction.wait(
                forDuration: StageResultDisplayParameters.perfectClearAnimationDelay
            ),
            growAction,
            restoreAction,
        ]))
    }

    private func recordSuccessfulLanding(_ result: HitResult) {
        switch result {
        case .perfect:
            perfectCount += 1
        case .goodLeft, .goodRight:
            goodCount += 1
        case .miss:
            return
        }
    }

    private func judgeFeedbackPosition(targetSkewerX: CGFloat) -> CGPoint {
        CGPoint(
            x: targetSkewerX,
            y: skewerTopY + JudgeFeedbackParameters.labelYOffset
        )
    }

    private func showJudgeFeedback(
        _ kind: JudgeFeedbackKind,
        at position: CGPoint
    ) {
        let text: String
        let fontSize: CGFloat
        let initialScale: CGFloat
        let popScale: CGFloat
        let color: SKColor

        switch kind {
        case .perfect:
            text = "PERFECT"
            fontSize = JudgeFeedbackParameters.perfectFontSize
            initialScale = JudgeFeedbackParameters.perfectInitialScale
            popScale = JudgeFeedbackParameters.perfectPopScale
            color = Appearance.perfectFeedbackColor
        case .good:
            text = "GOOD"
            fontSize = JudgeFeedbackParameters.standardFontSize
            initialScale = JudgeFeedbackParameters.standardInitialScale
            popScale = JudgeFeedbackParameters.goodPopScale
            color = Appearance.skewerColor
        case .wrong:
            text = "WRONG"
            fontSize = JudgeFeedbackParameters.standardFontSize
            initialScale = JudgeFeedbackParameters.standardInitialScale
            popScale = JudgeFeedbackParameters.failurePopScale
            color = FailureParameters.failedColor
        case .miss:
            text = "MISS"
            fontSize = JudgeFeedbackParameters.standardFontSize
            initialScale = JudgeFeedbackParameters.standardInitialScale
            popScale = JudgeFeedbackParameters.failurePopScale
            color = Appearance.missFeedbackColor
        }

        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = text
        label.fontSize = fontSize
        label.fontColor = color
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.position = position
        label.zPosition = 12
        label.setScale(initialScale)
        addChild(label)

        let popAction = SKAction.scale(
            to: popScale,
            duration: JudgeFeedbackParameters.popDuration
        )
        popAction.timingMode = .easeOut

        let settleAction = SKAction.scale(
            to: 1,
            duration: JudgeFeedbackParameters.settleDuration
        )
        settleAction.timingMode = .easeInEaseOut

        let exitAction = SKAction.group([
            SKAction.fadeOut(withDuration: JudgeFeedbackParameters.fadeDuration),
            SKAction.moveBy(
                x: 0,
                y: JudgeFeedbackParameters.riseDistance,
                duration: JudgeFeedbackParameters.fadeDuration
            ),
        ])
        exitAction.timingMode = .easeIn

        let lifecycleAction = SKAction.sequence([
            popAction,
            settleAction,
            exitAction,
        ])

        if case .wrong = kind {
            let shakeAmount = JudgeFeedbackParameters.wrongShakeAmount
            let shakeDuration = JudgeFeedbackParameters.wrongShakeStepDuration
            let shakeAction = SKAction.sequence([
                SKAction.moveBy(x: -shakeAmount, y: 0, duration: shakeDuration),
                SKAction.moveBy(x: shakeAmount * 2, y: 0, duration: shakeDuration),
                SKAction.moveBy(x: -shakeAmount, y: 0, duration: shakeDuration),
            ])
            label.run(SKAction.sequence([
                SKAction.group([lifecycleAction, shakeAction]),
                SKAction.removeFromParent(),
            ]))
        } else {
            label.run(SKAction.sequence([
                lifecycleAction,
                SKAction.removeFromParent(),
            ]))
        }
    }

    private func showPerfectRing(at position: CGPoint) {
        let ring = SKShapeNode(circleOfRadius: DangoParameters.diameter / 2)
        ring.fillColor = .clear
        ring.strokeColor = Appearance.perfectFeedbackColor
        ring.lineWidth = JudgeFeedbackParameters.perfectRingLineWidth
        ring.position = position
        ring.zPosition = 2
        ring.setScale(JudgeFeedbackParameters.perfectRingInitialScale)
        addChild(ring)

        let expandAction = SKAction.scale(
            to: JudgeFeedbackParameters.perfectRingFinalScale,
            duration: JudgeFeedbackParameters.perfectRingDuration
        )
        expandAction.timingMode = .easeOut
        ring.run(SKAction.sequence([
            SKAction.group([
                expandAction,
                SKAction.fadeOut(
                    withDuration: JudgeFeedbackParameters.perfectRingDuration
                ),
            ]),
            SKAction.removeFromParent(),
        ]))
    }

    private func triggerHaptic(for kind: JudgeFeedbackKind) {
        let style: UIImpactFeedbackGenerator.FeedbackStyle
        let intensity: CGFloat

        switch kind {
        case .perfect:
            style = .medium
            intensity = HapticParameters.perfectIntensity
        case .good:
            style = .light
            intensity = HapticParameters.goodIntensity
        case .wrong:
            style = .rigid
            intensity = HapticParameters.wrongIntensity
        case .miss:
            style = .soft
            intensity = HapticParameters.missIntensity
        }

        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred(intensity: intensity)
    }

    private func animateUnderlyingDango(_ underlyingDango: SKShapeNode) {
        let squashAction = SKAction.group([
            SKAction.scaleY(
                to: LandingAnimationParameters.underlyingSquashScaleY,
                duration: LandingAnimationParameters.underlyingSquashDuration
            ),
            SKAction.moveBy(
                x: 0,
                y: -LandingAnimationParameters.underlyingSinkAmount,
                duration: LandingAnimationParameters.underlyingSquashDuration
            ),
        ])
        squashAction.timingMode = .easeOut

        let restoreAction = SKAction.group([
            SKAction.scaleY(
                to: 1,
                duration: LandingAnimationParameters.underlyingRestoreDuration
            ),
            SKAction.moveBy(
                x: 0,
                y: LandingAnimationParameters.underlyingSinkAmount,
                duration: LandingAnimationParameters.underlyingRestoreDuration
            ),
        ])
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
        switch failureKind {
        case .miss:
            missCount += 1
        case .wrong:
            wrongCount += 1
        }

        print(
            "[Failure] \(failureKind.rawValue): "
                + "\(totalFailureCount)/\(FailureParameters.maximumCount)"
        )
        updateFailureHUD()

        if totalFailureCount >= FailureParameters.maximumCount {
            showStageFailed()
        } else {
            respawnTimeRemaining = DangoParameters.respawnDelay
        }
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

    private var totalFailureCount: Int {
        missCount + wrongCount
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
