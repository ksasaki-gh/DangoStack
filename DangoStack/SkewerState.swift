//
//  SkewerState.swift
//  DangoStack
//

import SpriteKit

struct SkewerState {
    static let maximumDangoCount = 3

    let xPositionRatio: CGFloat
    private(set) var dangoNodes: [SKShapeNode] = []

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

    mutating func addDangoNode(_ node: SKShapeNode) -> Bool {
        guard !isFull else { return false }
        dangoNodes.append(node)
        return true
    }
}
