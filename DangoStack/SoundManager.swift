//
//  SoundManager.swift
//  DangoStack
//

import AVFoundation

enum SoundEvent: String, CaseIterable {
    case tap
    case drop
    case perfect
    case good
    case wrong
    case miss
    case lifeBreak = "life_break"
    case dangoComplete = "dango_complete"
    case stageClear = "stage_clear"
    case perfectClear = "perfect_clear"
}

@MainActor
final class SoundManager {
    private static let supportedFileExtensions = ["wav", "caf", "m4a", "mp3"]

    private let settingsStore: SettingsStore
    private var players: [SoundEvent: AVAudioPlayer] = [:]
    private var missingEvents: Set<SoundEvent> = []

    init(settingsStore: SettingsStore) {
        self.settingsStore = settingsStore
    }

    func play(_ event: SoundEvent) {
        guard settingsStore.isSoundEnabled else { return }
        guard let player = player(for: event) else { return }

        player.currentTime = 0
        player.play()
    }

    private func player(for event: SoundEvent) -> AVAudioPlayer? {
        if let player = players[event] {
            return player
        }
        guard !missingEvents.contains(event) else { return nil }

        guard let url = Self.supportedFileExtensions.lazy.compactMap({ fileExtension in
            Bundle.main.url(
                forResource: event.rawValue,
                withExtension: fileExtension
            )
        }).first else {
            missingEvents.insert(event)
            return nil
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            players[event] = player
            return player
        } catch {
            missingEvents.insert(event)
            print("[SoundManager] Failed to load \(event.rawValue): \(error)")
            return nil
        }
    }
}
