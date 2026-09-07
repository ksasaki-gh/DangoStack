//
//  StageSelectView.swift
//  DangoStack
//

import Foundation
import SwiftUI

struct StageSelectView: View {
    @ObservedObject var appState: AppState

    var body: some View {
        ZStack {
            DangoTheme.background.ignoresSafeArea()

            VStack(spacing: 12) {
                header

                ScrollView {
                    LazyVStack(spacing: 14) {
                        ForEach(0..<7, id: \.self) { sectionIndex in
                            stageSection(sectionIndex)
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 8)
                }
            }
        }
    }

    private var header: some View {
        ZStack {
            Text("STAGE SELECT")
                .font(.title2.weight(.black))
                .foregroundStyle(DangoTheme.text)
                .accessibilityAddTraits(.isHeader)

            HStack {
                Button {
                    appState.showTitle()
                } label: {
                    Label("TITLE", systemImage: "chevron.left")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(DangoTheme.text)
                        .padding(.vertical, 8)
                }

                Spacer()
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 8)
    }

    private func stageSection(_ sectionIndex: Int) -> some View {
        HStack(spacing: 10) {
            ForEach(0..<3, id: \.self) { columnIndex in
                let stageNumber = sectionIndex * 3 + columnIndex + 1
                StageSelectButton(
                    stageNumber: stageNumber,
                    isUnlocked: appState.progress.isUnlocked(stageNumber),
                    bestStars: appState.progress.bestStars(for: stageNumber),
                    isPerfectClear: appState.progress.hasPerfectClear(
                        for: stageNumber
                    )
                ) {
                    appState.selectStage(stageNumber)
                }
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(sectionIndex.isMultiple(of: 2)
                    ? DangoTheme.pink.opacity(0.07)
                    : DangoTheme.green.opacity(0.08))
        )
    }
}

private struct StageSelectButton: View {
    let stageNumber: Int
    let isUnlocked: Bool
    let bestStars: Int?
    let isPerfectClear: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                HStack(spacing: 4) {
                    Text(String(format: "%02d", stageNumber))
                        .font(.title3.monospacedDigit().weight(.black))

                    if !isUnlocked {
                        Image(systemName: "lock.fill")
                            .font(.caption2)
                    }
                }

                if isUnlocked {
                    Text(starsText)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(DangoTheme.pink)

                    Image(systemName: "crown.fill")
                        .font(.caption)
                        .foregroundStyle(isPerfectClear ? .yellow : .clear)
                        .accessibilityHidden(true)
                } else {
                    Text("LOCKED")
                        .font(.caption2.weight(.bold))
                    Spacer().frame(height: 14)
                }
            }
            .foregroundStyle(isUnlocked ? DangoTheme.text : DangoTheme.locked)
            .frame(maxWidth: .infinity)
            .frame(height: 78)
            .background(
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .fill(.white.opacity(isUnlocked ? 0.78 : 0.40))
            )
            .overlay {
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .stroke(
                        isPerfectClear
                            ? Color.yellow.opacity(0.85)
                            : DangoTheme.text.opacity(0.10),
                        lineWidth: isPerfectClear ? 2 : 1
                    )
            }
        }
        .buttonStyle(.plain)
        .disabled(!isUnlocked)
        .accessibilityLabel("Stage \(stageNumber)")
        .accessibilityValue(accessibilityValue)
        .accessibilityHint(isUnlocked ? "Starts this stage" : "Locked")
    }

    private var starsText: String {
        guard let bestStars else { return "---" }
        let clampedStars = min(max(bestStars, 0), StageResult.maximumStars)
        return String(repeating: "★", count: clampedStars)
            + String(
                repeating: "☆",
                count: StageResult.maximumStars - clampedStars
            )
    }

    private var accessibilityValue: String {
        guard isUnlocked else { return "Locked" }

        var values = [String]()
        if let bestStars {
            values.append("Best \(bestStars) stars")
        } else {
            values.append("Not cleared")
        }
        if isPerfectClear {
            values.append("Perfect Clear achieved")
        }
        return values.joined(separator: ", ")
    }
}

#Preview {
    StageSelectView(appState: AppState())
}
