//
//  HapticManager.swift
//  DangoStack
//

import UIKit

enum HapticEvent {
    case perfect
    case good
    case failure
    case lifeBreak
    case stageClear
    case perfectClear
}

@MainActor
final class HapticManager {
    private enum Intensity {
        static let good: CGFloat = 0.35
        static let perfect: CGFloat = 0.72
        static let failure: CGFloat = 0.42
        static let lifeBreak: CGFloat = 0.68
        static let stageClear: CGFloat = 0.62
    }

    private let settingsStore: SettingsStore
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let softImpact = UIImpactFeedbackGenerator(style: .soft)
    private let rigidImpact = UIImpactFeedbackGenerator(style: .rigid)
    private let notification = UINotificationFeedbackGenerator()

    init(settingsStore: SettingsStore) {
        self.settingsStore = settingsStore
    }

    func prepareForGameplay() {
        guard settingsStore.isHapticsEnabled else { return }
        lightImpact.prepare()
        mediumImpact.prepare()
        softImpact.prepare()
        rigidImpact.prepare()
        notification.prepare()
    }

    func play(_ event: HapticEvent) {
        guard settingsStore.isHapticsEnabled else { return }

        switch event {
        case .good:
            lightImpact.prepare()
            lightImpact.impactOccurred(intensity: Intensity.good)
        case .perfect:
            mediumImpact.prepare()
            mediumImpact.impactOccurred(intensity: Intensity.perfect)
        case .failure:
            softImpact.prepare()
            softImpact.impactOccurred(intensity: Intensity.failure)
        case .lifeBreak:
            rigidImpact.prepare()
            rigidImpact.impactOccurred(intensity: Intensity.lifeBreak)
        case .stageClear:
            mediumImpact.prepare()
            mediumImpact.impactOccurred(intensity: Intensity.stageClear)
        case .perfectClear:
            notification.prepare()
            notification.notificationOccurred(.success)
        }
    }
}
