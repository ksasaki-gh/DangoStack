//
//  StageManager.swift
//  DangoStack
//

struct StageManager {
    static let validStageNumbers = 1...21

    private(set) var currentStageNumber: Int

    init(initialStageNumber: Int = 1) {
        currentStageNumber = Self.isValid(stageNumber: initialStageNumber)
            ? initialStageNumber
            : Self.validStageNumbers.lowerBound
    }

    var currentConfig: StageConfig {
        StageConfigs.config(for: currentStageNumber) ?? StageConfigs.all[0]
    }

    var nextConfig: StageConfig? {
        StageConfigs.config(for: currentStageNumber + 1)
    }

    var previousConfig: StageConfig? {
        StageConfigs.config(for: currentStageNumber - 1)
    }

    @discardableResult
    mutating func selectStage(_ stageNumber: Int) -> Bool {
        guard Self.isValid(stageNumber: stageNumber) else { return false }
        currentStageNumber = stageNumber
        return true
    }

    @discardableResult
    mutating func moveToNextStage() -> Bool {
        selectStage(currentStageNumber + 1)
    }

    @discardableResult
    mutating func moveToPreviousStage() -> Bool {
        selectStage(currentStageNumber - 1)
    }

    static func isValid(stageNumber: Int) -> Bool {
        validStageNumbers.contains(stageNumber)
            && StageConfigs.config(for: stageNumber) != nil
    }
}
