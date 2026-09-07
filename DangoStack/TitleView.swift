//
//  TitleView.swift
//  DangoStack
//

import SwiftUI

struct TitleView: View {
    @ObservedObject var appState: AppState

    var body: some View {
        ZStack {
            DangoTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 36)

                Text("DANGO\nSTACK")
                    .font(.system(size: 52, weight: .black, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(DangoTheme.text)
                    .lineSpacing(-7)
                    .accessibilityAddTraits(.isHeader)

                DangoLogoView()
                    .padding(.top, 20)

                Spacer()

                VStack(spacing: 14) {
                    Button("PLAY") {
                        appState.play()
                    }
                    .buttonStyle(DangoPrimaryButtonStyle())

                    Button("STAGE SELECT") {
                        appState.showStageSelect()
                    }
                    .buttonStyle(DangoSecondaryButtonStyle())

                    Button("SETTINGS") {
                        appState.showSettingsFromTitle()
                    }
                    .buttonStyle(DangoSecondaryButtonStyle())
                }
                .frame(maxWidth: 320)

                Spacer(minLength: 44)
            }
            .padding(.horizontal, 28)
        }
    }
}

#Preview {
    TitleView(appState: AppState())
}
