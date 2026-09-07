//
//  TutorialStore.swift
//  DangoStack
//

import Combine
import Foundation

@MainActor
final class TutorialStore: ObservableObject {
    static let userDefaultsKey = "dangoStack.hasSeenTutorial"

    @Published private(set) var hasSeenTutorial: Bool

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        hasSeenTutorial = userDefaults.bool(forKey: Self.userDefaultsKey)
    }

    func markAsSeen() {
        guard !hasSeenTutorial else { return }
        hasSeenTutorial = true
        userDefaults.set(true, forKey: Self.userDefaultsKey)
    }

    func resetForReplay() {
        hasSeenTutorial = false
        userDefaults.set(false, forKey: Self.userDefaultsKey)
    }
}
