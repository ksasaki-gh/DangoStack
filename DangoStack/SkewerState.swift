//
//  SkewerState.swift
//  DangoStack
//

import SpriteKit

struct SkewerState {
    static let maximumDangoCount = 3

    let xPositionRatio: CGFloat
    private(set) var dangoNodes: [SKShapeNode] = []
    private(set) var perfectJudgements: [Bool] = []

    var dangoCount: Int {
        dangoNodes.count
    }

    var nextRequiredColor: DangoColor? {
        guard dangoCount < DangoColor.stackOrder.count else { return nil }
        return DangoColor.stackOrder[dangoCount]
    }

    var isFull: Bool {
        dangoCount >= Self.maximumDangoCount
    }

    var isPerfectDango: Bool {
        isFull
            && perfectJudgements.count == Self.maximumDangoCount
            && perfectJudgements.allSatisfy { $0 }
    }

    mutating func addDangoNode(
        _ node: SKShapeNode,
        wasPerfect: Bool
    ) -> Bool {
        guard !isFull else { return false }
        dangoNodes.append(node)
        perfectJudgements.append(wasPerfect)
        return true
    }
}
