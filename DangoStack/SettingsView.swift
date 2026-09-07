//
//  SettingsView.swift
//  DangoStack
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var settingsStore: SettingsStore
    @ObservedObject var consentManager: ConsentManager
    let onBack: () -> Void
    let onReplayTutorial: () -> Void
    let onPrivacyOptions: () -> Void

    var body: some View {
        ZStack {
            DangoTheme.background.ignoresSafeArea()

            VStack(spacing: 24) {
                header

                VStack(spacing: 0) {
                    settingToggle(
                        title: "Sound",
                        isOn: $settingsStore.isSoundEnabled
                    )

                    Divider()
                        .overlay(DangoTheme.text.opacity(0.12))

                    settingToggle(
                        title: "Haptics",
                        isOn: $settingsStore.isHapticsEnabled
                    )

                    Divider()
                        .overlay(DangoTheme.text.opacity(0.12))

                    Button("REPLAY TUTORIAL", action: onReplayTutorial)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(DangoTheme.green)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 18)
                        .accessibilityHint("Starts the Stage 1 tutorial")

                    if consentManager.isPrivacyOptionsRequired {
                        Divider()
                            .overlay(DangoTheme.text.opacity(0.12))

                        Button("PRIVACY OPTIONS", action: onPrivacyOptions)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(DangoTheme.green)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 18)
                            .accessibilityHint("Review advertising privacy choices")
                    }
                }
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(.white.opacity(0.72))
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(DangoTheme.text.opacity(0.10), lineWidth: 1)
                }
                .frame(maxWidth: 360)

                Spacer()
            }
            .padding(.horizontal, 24)
        }
    }

    private var header: some View {
        ZStack {
            Text("SETTINGS")
                .font(.title2.weight(.black))
                .foregroundStyle(DangoTheme.text)
                .accessibilityAddTraits(.isHeader)

            HStack {
                Button {
                    onBack()
                } label: {
                    Label("BACK", systemImage: "chevron.left")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(DangoTheme.text)
                        .padding(.vertical, 8)
                }

                Spacer()
            }
        }
        .padding(.top, 8)
    }

    private func settingToggle(
        title: String,
        isOn: Binding<Bool>
    ) -> some View {
        Toggle(title, isOn: isOn)
            .font(.headline.weight(.semibold))
            .foregroundStyle(DangoTheme.text)
            .tint(DangoTheme.pink)
            .padding(.vertical, 18)
            .accessibilityLabel(title)
    }
}

#Preview {
    SettingsView(
        settingsStore: SettingsStore(),
        consentManager: ConsentManager(),
        onBack: {},
        onReplayTutorial: {},
        onPrivacyOptions: {}
    )
}
