//
//  StageResult.swift
//  DangoStack
//

struct StageResult: Equatable {
    static let maximumStars = 3
    static let requiredDangoCount = 9

    let stars: Int
    let isPerfectClear: Bool
    let perfectCount: Int
    let goodCount: Int
    let missCount: Int
    let wrongCount: Int

    init(
        isStageClear: Bool,
        perfectCount: Int,
        goodCount: Int,
        missCount: Int,
        wrongCount: Int
    ) {
        self.perfectCount = perfectCount
        self.goodCount = goodCount
        self.missCount = missCount
        self.wrongCount = wrongCount

        let totalFailureCount = missCount + wrongCount
        let clampedFailureCount = min(
            max(totalFailureCount, 0),
            Self.maximumStars
        )
        stars = isStageClear
            ? Self.maximumStars - clampedFailureCount
            : 0

        isPerfectClear = isStageClear
            && perfectCount == Self.requiredDangoCount
            && goodCount == 0
            && missCount == 0
            && wrongCount == 0
            && totalFailureCount == 0
    }

    var starsText: String {
        String(repeating: "★", count: stars)
            + String(repeating: "☆", count: Self.maximumStars - stars)
    }
}
