//
//  DangoQueue.swift
//  DangoStack
//

struct DangoQueue {
    static let countPerColor = 3

    private var bag: [DangoColor] = []

    mutating func dequeue() -> DangoColor {
        if bag.isEmpty {
            refillBag()
        }

        return bag.removeLast()
    }

    private mutating func refillBag() {
        bag = DangoColor.allCases.flatMap { color in
            Array(repeating: color, count: Self.countPerColor)
        }
        bag.shuffle()
    }
}
