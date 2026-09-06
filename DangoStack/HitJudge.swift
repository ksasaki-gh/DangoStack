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
        skewerCenterXs: [CGFloat],
        perfectThresholdScale: CGFloat = 1,
        goodThresholdScale: CGFloat = 1
    ) -> HitResult {
        guard let nearestSkewerX = nearestSkewerCenterX(
            dangoX: dangoX,
            skewerCenterXs: skewerCenterXs
        ) else {
            return .miss
        }

        let horizontalOffset = dangoX - nearestSkewerX
        let horizontalDistance = abs(horizontalOffset)

        let perfectThreshold = dangoDiameter
            * perfectThresholdRatio
            * max(perfectThresholdScale, 0)
        let goodThreshold = dangoDiameter
            * goodThresholdRatio
            * max(goodThresholdScale, 0)

        if horizontalDistance <= perfectThreshold {
            return .perfect
        }

        if horizontalDistance <= goodThreshold {
            return horizontalOffset < 0 ? .goodLeft : .goodRight
        }

        return .miss
    }

    static func nearestSkewerCenterX(
        dangoX: CGFloat,
        skewerCenterXs: [CGFloat]
    ) -> CGFloat? {
        guard let index = nearestSkewerIndex(
            dangoX: dangoX,
            skewerCenterXs: skewerCenterXs
        ) else { return nil }

        return skewerCenterXs[index]
    }

    static func nearestSkewerIndex(
        dangoX: CGFloat,
        skewerCenterXs: [CGFloat]
    ) -> Int? {
        skewerCenterXs.indices.min(by: {
            abs(dangoX - skewerCenterXs[$0])
                < abs(dangoX - skewerCenterXs[$1])
        })
    }
}
