//
//  HitJudge.swift
//  DangoStack
//

import CoreGraphics

enum HitResult {
    case perfect
    case goodLeft
    case goodRight
    case miss
}

struct HitJudge {
    static let perfectThresholdRatio: CGFloat = 0.20
    static let goodThresholdRatio: CGFloat = 0.38

    static func judge(
        dangoX: CGFloat,
        dangoDiameter: CGFloat,
        skewerCenterXs: [CGFloat]
    ) -> HitResult {
        guard let nearestSkewerX = nearestSkewerCenterX(
            dangoX: dangoX,
            skewerCenterXs: skewerCenterXs
        ) else {
            return .miss
        }

        let horizontalOffset = dangoX - nearestSkewerX
        let horizontalDistance = abs(horizontalOffset)

        if horizontalDistance <= dangoDiameter * perfectThresholdRatio {
            return .perfect
        }

        if horizontalDistance <= dangoDiameter * goodThresholdRatio {
            return horizontalOffset < 0 ? .goodLeft : .goodRight
        }

        return .miss
    }

    static func nearestSkewerCenterX(
        dangoX: CGFloat,
        skewerCenterXs: [CGFloat]
    ) -> CGFloat? {
        skewerCenterXs.min(by: {
            abs(dangoX - $0) < abs(dangoX - $1)
        })
    }
}
