//
//  PauseOverlayView.swift
//  DangoStack
//

import SwiftUI

struct PauseOverlayView: View {
    let onResume: () -> Void
    let onRestart: () -> Void
    let onSettings: () -> Void
    let onStageSelect: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.36)
                .ignoresSafeArea()

            VStack(spacing: 14) {
                Text("PAUSED")
                    .font(.system(size: 38, weight: .black, design: .rounded))
                    .foregroundStyle(DangoTheme.text)
                    .padding(.bottom, 8)
                    .accessibilityAddTraits(.isHeader)

                Button("RESUME", action: onResume)
                    .buttonStyle(DangoPrimaryButtonStyle())

                Button("RESTART", action: onRestart)
                    .buttonStyle(DangoSecondaryButtonStyle())

                Button("SETTINGS", action: onSettings)
                    .buttonStyle(DangoSecondaryButtonStyle())

                Button("STAGE SELECT", action: onStageSelect)
                    .buttonStyle(DangoSecondaryButtonStyle())
            }
            .frame(maxWidth: 300)
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(DangoTheme.background)
            )
            .shadow(color: .black.opacity(0.18), radius: 18, y: 8)
            .padding(.horizontal, 28)
        }
    }
}

#Preview {
    PauseOverlayView(
        onResume: {},
        onRestart: {},
        onSettings: {},
        onStageSelect: {}
    )
}
