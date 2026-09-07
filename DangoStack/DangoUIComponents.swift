//
//  DangoUIComponents.swift
//  DangoStack
//

import SwiftUI

enum DangoTheme {
    static let background = Color(
        red: 0.98,
        green: 0.96,
        blue: 0.91
    )
    static let text = Color(
        red: 0.28,
        green: 0.20,
        blue: 0.16
    )
    static let pink = Color(
        red: 0.94,
        green: 0.47,
        blue: 0.61
    )
    static let green = Color(
        red: 0.47,
        green: 0.69,
        blue: 0.39
    )
    static let whiteDango = Color(
        red: 1.0,
        green: 0.99,
        blue: 0.96
    )
    static let skewer = Color(
        red: 0.48,
        green: 0.30,
        blue: 0.17
    )
    static let locked = Color(
        red: 0.62,
        green: 0.59,
        blue: 0.55
    )
}

struct DangoLogoView: View {
    var compact = false

    var body: some View {
        let diameter: CGFloat = compact ? 30 : 52

        ZStack {
            Capsule()
                .fill(DangoTheme.skewer)
                .frame(width: compact ? 5 : 7, height: compact ? 82 : 138)
                .offset(y: compact ? 22 : 36)

            VStack(spacing: compact ? -5 : -9) {
                dangoCircle(color: DangoTheme.pink, diameter: diameter)
                dangoCircle(color: DangoTheme.whiteDango, diameter: diameter)
                dangoCircle(color: DangoTheme.green, diameter: diameter)
            }
        }
        .frame(
            width: compact ? 50 : 88,
            height: compact ? 105 : 178
        )
        .accessibilityHidden(true)
    }

    private func dangoCircle(color: Color, diameter: CGFloat) -> some View {
        Circle()
            .fill(color)
            .overlay {
                Circle()
                    .stroke(DangoTheme.text.opacity(0.16), lineWidth: 1.5)
            }
            .shadow(color: DangoTheme.text.opacity(0.12), radius: 2, y: 1)
            .frame(width: diameter, height: diameter)
    }
}

struct DangoPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.bold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(DangoTheme.pink)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.10), value: configuration.isPressed)
    }
}

struct DangoSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(DangoTheme.text)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(DangoTheme.green, lineWidth: 2)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.white.opacity(0.55))
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.10), value: configuration.isPressed)
    }
}
