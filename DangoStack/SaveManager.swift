//
//  SaveManager.swift
//  DangoStack
//

import Combine
import Foundation

struct StageProgress: Codable, Equatable, Identifiable {
    let stageNumber: Int
    private(set) var bestStars: Int
    private(set) var isPerfectClear: Bool

    var id: Int { stageNumber }

    init(
        stageNumber: Int,
        bestStars: Int = 0,
        isPerfectClear: Bool = false
    ) {
        self.stageNumber = stageNumber
        self.bestStars = min(max(bestStars, 0), StageResult.maximumStars)
        self.isPerfectClear = isPerfectClear
    }

    mutating func record(result: StageResult) {
        bestStars = max(bestStars, result.stars)
        isPerfectClear = isPerfectClear || result.isPerfectClear
    }
}

struct GameProgress: Codable, Equatable {
    static let currentSaveVersion = 1

    let saveVersion: Int
    private(set) var unlockedStage: Int
    private(set) var stages: [StageProgress]

    static var initial: GameProgress {
        GameProgress(
            saveVersion: currentSaveVersion,
            unlockedStage: StageManager.validStageNumbers.lowerBound,
            stages: StageManager.validStageNumbers.map {
                StageProgress(stageNumber: $0)
            }
        )
    }

    func stageProgress(for stageNumber: Int) -> StageProgress? {
        stages.first { $0.stageNumber == stageNumber }
    }

    mutating func recordClear(stageNumber: Int, result: StageResult) {
        guard StageManager.isValid(stageNumber: stageNumber) else { return }
        guard let stageIndex = stages.firstIndex(where: {
            $0.stageNumber == stageNumber
        }) else { return }

        stages[stageIndex].record(result: result)

        let nextUnlockedStage = min(
            stageNumber + 1,
            StageManager.validStageNumbers.upperBound
        )
        unlockedStage = max(unlockedStage, nextUnlockedStage)
    }

    static func normalized(_ savedProgress: GameProgress) -> GameProgress? {
        guard savedProgress.saveVersion == currentSaveVersion else {
            return nil
        }

        let normalizedStages = StageManager.validStageNumbers.map { stageNumber in
            let savedStage = savedProgress.stages.last {
                $0.stageNumber == stageNumber
            }
            let isPerfectClear = savedStage?.isPerfectClear ?? false
            let savedStars = savedStage?.bestStars ?? 0
            let bestStars = isPerfectClear
                ? StageResult.maximumStars
                : min(max(savedStars, 0), StageResult.maximumStars)

            return StageProgress(
                stageNumber: stageNumber,
                bestStars: bestStars,
                isPerfectClear: isPerfectClear
            )
        }

        let validRange = StageManager.validStageNumbers
        let savedUnlockedStage = min(
            max(savedProgress.unlockedStage, validRange.lowerBound),
            validRange.upperBound
        )
        let highestClearedStage = normalizedStages.last {
            $0.bestStars > 0
        }?.stageNumber
        let minimumUnlockedStage = highestClearedStage.map {
            min($0 + 1, validRange.upperBound)
        } ?? validRange.lowerBound

        return GameProgress(
            saveVersion: currentSaveVersion,
            unlockedStage: max(savedUnlockedStage, minimumUnlockedStage),
            stages: normalizedStages
        )
    }
}

@MainActor
final class SaveManager: ObservableObject {
    static let userDefaultsKey = "dangoStack.gameProgress"

    @Published private(set) var progress: GameProgress

    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults

        if let savedProgress = Self.loadProgress(
            from: userDefaults,
            decoder: decoder
        ) {
            progress = savedProgress
        } else {
            progress = .initial
            Self.save(
                progress,
                to: userDefaults,
                encoder: encoder
            )
        }
    }

    var unlockedStage: Int {
        progress.unlockedStage
    }

    var hasClearedAllStages: Bool {
        bestStars(for: StageManager.validStageNumbers.upperBound) > 0
    }

    func isUnlocked(_ stageNumber: Int) -> Bool {
        StageManager.isValid(stageNumber: stageNumber)
            && stageNumber <= unlockedStage
    }

    func bestStars(for stageNumber: Int) -> Int {
        progress.stageProgress(for: stageNumber)?.bestStars ?? 0
    }

    func hasPerfectClear(for stageNumber: Int) -> Bool {
        progress.stageProgress(for: stageNumber)?.isPerfectClear ?? false
    }

    func recordStageClear(stageNumber: Int, result: StageResult) {
        var updatedProgress = progress
        updatedProgress.recordClear(stageNumber: stageNumber, result: result)
        guard updatedProgress != progress else { return }

        progress = updatedProgress
        persistProgress()
    }

#if DEBUG
    func resetProgressForDebug() {
        progress = .initial
        persistProgress()
    }
#endif

    private func persistProgress() {
        Self.save(progress, to: userDefaults, encoder: encoder)
    }

    private static func loadProgress(
        from userDefaults: UserDefaults,
        decoder: JSONDecoder
    ) -> GameProgress? {
        guard let data = userDefaults.data(forKey: userDefaultsKey) else {
            return nil
        }

        do {
            let decodedProgress = try decoder.decode(GameProgress.self, from: data)
            return GameProgress.normalized(decodedProgress)
        } catch {
#if DEBUG
            print("[SaveManager] Failed to decode progress: \(error)")
#endif
            return nil
        }
    }

    private static func save(
        _ progress: GameProgress,
        to userDefaults: UserDefaults,
        encoder: JSONEncoder
    ) {
        do {
            let data = try encoder.encode(progress)
            userDefaults.set(data, forKey: userDefaultsKey)
        } catch {
#if DEBUG
            print("[SaveManager] Failed to encode progress: \(error)")
#endif
        }
    }
}
