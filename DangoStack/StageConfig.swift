//
//  StageConfig.swift
//  DangoStack
//

import CoreGraphics
import Foundation

struct StageConfig: Equatable {
    let stageNumber: Int
    let dangoHorizontalSpeed: CGFloat
    let skewerMovementAmount: CGFloat
    let skewerMovementSpeed: CGFloat
    let skewerWidthScale: CGFloat
    let perfectJudgeScale: CGFloat
    let goodJudgeScale: CGFloat
}

enum StageConfigs {
    private enum Level {
        case level1
        case level2
        case level3
    }

    // A：団子の横移動速度
    static let baseHorizontalSpeed: CGFloat = 140
    static let aLevel1SpeedMultiplier: CGFloat = 1.10
    static let aLevel2SpeedMultiplier: CGFloat = 1.25
    static let aLevel3SpeedMultiplier: CGFloat = 1.40

    // B：串グループの移動量（画面幅比）と1往復の時間
    static let bLevel1MovementAmount: CGFloat = 0.020
    static let bLevel1CycleDuration: TimeInterval = 5.0
    static let bLevel2MovementAmount: CGFloat = 0.035
    static let bLevel2CycleDuration: TimeInterval = 4.2
    static let bLevel3MovementAmount: CGFloat = 0.050
    static let bLevel3CycleDuration: TimeInterval = 3.5

    // C：串の見た目とPERFECT / GOOD判定幅
    static let cLevel1SkewerWidthScale: CGFloat = 0.90
    static let cLevel1PerfectJudgeScale: CGFloat = 0.90
    static let cLevel1GoodJudgeScale: CGFloat = 0.90
    static let cLevel2SkewerWidthScale: CGFloat = 0.80
    static let cLevel2PerfectJudgeScale: CGFloat = 0.80
    static let cLevel2GoodJudgeScale: CGFloat = 0.80
    static let cLevel3SkewerWidthScale: CGFloat = 0.70
    static let cLevel3PerfectJudgeScale: CGFloat = 0.70
    static let cLevel3GoodJudgeScale: CGFloat = 0.70

    static let all: [StageConfig] = [
        // Section 1：A
        config(1, a: .level1),
        config(2, a: .level2),
        config(3, a: .level3),

        // Section 2：B
        config(4, b: .level1),
        config(5, b: .level2),
        config(6, b: .level3),

        // Section 3：C
        config(7, c: .level1),
        config(8, c: .level2),
        config(9, c: .level3),

        // Section 4：A + B
        config(10, a: .level1, b: .level1),
        config(11, a: .level2, b: .level2),
        config(12, a: .level3, b: .level3),

        // Section 5：A + C
        config(13, a: .level1, c: .level1),
        config(14, a: .level2, c: .level2),
        config(15, a: .level3, c: .level3),

        // Section 6：B + C
        config(16, b: .level1, c: .level1),
        config(17, b: .level2, c: .level2),
        config(18, b: .level3, c: .level3),

        // Section 7：A + B + C
        config(19, a: .level1, b: .level1, c: .level1),
        config(20, a: .level2, b: .level2, c: .level2),
        config(21, a: .level3, b: .level3, c: .level3),
    ]

    static func config(for stageNumber: Int) -> StageConfig? {
        all.first { $0.stageNumber == stageNumber }
    }

    private static func config(
        _ stageNumber: Int,
        a: Level? = nil,
        b: Level? = nil,
        c: Level? = nil
    ) -> StageConfig {
        let cScales = cValues(for: c)
        return StageConfig(
            stageNumber: stageNumber,
            dangoHorizontalSpeed: baseHorizontalSpeed * aSpeedMultiplier(for: a),
            skewerMovementAmount: bMovementAmount(for: b),
            skewerMovementSpeed: bAngularSpeed(for: b),
            skewerWidthScale: cScales.skewerWidth,
            perfectJudgeScale: cScales.perfectJudge,
            goodJudgeScale: cScales.goodJudge
        )
    }

    private static func aSpeedMultiplier(for level: Level?) -> CGFloat {
        switch level {
        case .level1:
            return aLevel1SpeedMultiplier
        case .level2:
            return aLevel2SpeedMultiplier
        case .level3:
            return aLevel3SpeedMultiplier
        case nil:
            return 1
        }
    }

    private static func bMovementAmount(for level: Level?) -> CGFloat {
        switch level {
        case .level1:
            return bLevel1MovementAmount
        case .level2:
            return bLevel2MovementAmount
        case .level3:
            return bLevel3MovementAmount
        case nil:
            return 0
        }
    }

    private static func bAngularSpeed(for level: Level?) -> CGFloat {
        let cycleDuration: TimeInterval
        switch level {
        case .level1:
            cycleDuration = bLevel1CycleDuration
        case .level2:
            cycleDuration = bLevel2CycleDuration
        case .level3:
            cycleDuration = bLevel3CycleDuration
        case nil:
            return 0
        }

        return CGFloat.pi * 2 / max(CGFloat(cycleDuration), 0.01)
    }

    private static func cValues(
        for level: Level?
    ) -> (skewerWidth: CGFloat, perfectJudge: CGFloat, goodJudge: CGFloat) {
        switch level {
        case .level1:
            return (
                cLevel1SkewerWidthScale,
                cLevel1PerfectJudgeScale,
                cLevel1GoodJudgeScale
            )
        case .level2:
            return (
                cLevel2SkewerWidthScale,
                cLevel2PerfectJudgeScale,
                cLevel2GoodJudgeScale
            )
        case .level3:
            return (
                cLevel3SkewerWidthScale,
                cLevel3PerfectJudgeScale,
                cLevel3GoodJudgeScale
            )
        case nil:
            return (1, 1, 1)
        }
    }
}
