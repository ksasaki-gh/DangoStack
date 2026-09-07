//
//  SettingsStore.swift
//  DangoStack
//

import Combine
import Foundation

@MainActor
final class SettingsStore: ObservableObject {
    static let soundEnabledKey = "dangoStack.settings.soundEnabled"
    static let hapticsEnabledKey = "dangoStack.settings.hapticsEnabled"

    @Published var isSoundEnabled: Bool {
        didSet {
            userDefaults.set(isSoundEnabled, forKey: Self.soundEnabledKey)
        }
    }

    @Published var isHapticsEnabled: Bool {
        didSet {
            userDefaults.set(isHapticsEnabled, forKey: Self.hapticsEnabledKey)
        }
    }

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults

        if userDefaults.object(forKey: Self.soundEnabledKey) == nil {
            isSoundEnabled = true
            userDefaults.set(true, forKey: Self.soundEnabledKey)
        } else {
            isSoundEnabled = userDefaults.bool(forKey: Self.soundEnabledKey)
        }

        if userDefaults.object(forKey: Self.hapticsEnabledKey) == nil {
            isHapticsEnabled = true
            userDefaults.set(true, forKey: Self.hapticsEnabledKey)
        } else {
            isHapticsEnabled = userDefaults.bool(forKey: Self.hapticsEnabledKey)
        }
    }
}
