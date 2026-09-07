//
//  ResultView.swift
//  DangoStack
//

import SwiftUI

struct ResultView: View {
    @ObservedObject var appState: AppState
    let outcome: GameOutcome

    @State private var perfectClearScale: CGFloat = 0.82

    var body: some View {
        ZStack {
            DangoTheme.background.ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer(minLength: 24)

                Text("STAGE \(appState.selectedStageNumber)")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(DangoTheme.text.opacity(0.72))

                switch outcome {
                case .cleared(let result):
                    clearResult(result)
                case .failed:
                    failedResult
                }

                Spacer(minLength: 24)
            }
            .padding(.horizontal, 28)
        }
    }

    private func clearResult(_ result: StageResult) -> some View {
        Group {
            Text("CLEAR!")
                .font(.system(size: 46, weight: .black, design: .rounded))
                .foregroundStyle(DangoTheme.text)
                .accessibilityAddTraits(.isHeader)

            Text(result.starsText)
                .font(.system(size: 52, weight: .bold, design: .rounded))
                .foregroundStyle(DangoTheme.pink)
                .accessibilityLabel("\(result.stars) stars")

            if result.isPerfectClear {
                HStack(spacing: 10) {
                    DangoLogoView(compact: true)

                    Text("PERFECT\nCLEAR!")
                        .font(.title2.weight(.black))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(DangoTheme.green)
                }
                .scaleEffect(perfectClearScale)
                .onAppear {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.58)) {
                        perfectClearScale = 1
                    }
                }
            }

            VStack(spacing: 10) {
                resultRow(label: "PERFECT", value: result.perfectCount)
                resultRow(label: "GOOD", value: result.goodCount)
            }
            .frame(maxWidth: 260)
            .padding(.vertical, 16)

            if appState.selectedStageNumber
                == StageManager.validStageNumbers.upperBound {
                Text("ALL STAGES CLEAR!")
                    .font(.title3.weight(.black))
                    .foregroundStyle(DangoTheme.green)
            }

            resultButtons(isClear: true)
        }
    }

    private var failedResult: some View {
        Group {
            Text("STAGE FAILED")
                .font(.system(size: 40, weight: .black, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(DangoTheme.text)
                .accessibilityAddTraits(.isHeader)

            Text("TRY AGAIN")
                .font(.body.weight(.semibold))
                .foregroundStyle(DangoTheme.text.opacity(0.72))

            resultButtons(isClear: false)
        }
    }

    private func resultButtons(isClear: Bool) -> some View {
        VStack(spacing: 12) {
            if isClear
                && appState.selectedStageNumber
                    < StageManager.validStageNumbers.upperBound {
                Button("NEXT STAGE") {
                    appState.playNextStage()
                }
                .buttonStyle(DangoPrimaryButtonStyle())
            }

            if isClear {
                Button("RETRY") {
                    appState.retryStage()
                }
                .buttonStyle(DangoSecondaryButtonStyle())
            } else {
                Button("RETRY") {
                    appState.retryStage()
                }
                .buttonStyle(DangoPrimaryButtonStyle())
            }

            Button("STAGE SELECT") {
                appState.showStageSelect()
            }
            .buttonStyle(DangoSecondaryButtonStyle())

            if isClear
                && appState.selectedStageNumber
                    == StageManager.validStageNumbers.upperBound {
                Button("TITLE") {
                    appState.showTitle()
                }
                .buttonStyle(DangoSecondaryButtonStyle())
            }
        }
        .frame(maxWidth: 320)
    }

    private func resultRow(label: String, value: Int) -> some View {
        HStack {
            Text(label)
                .font(.headline.weight(.bold))
            Spacer()
            Text("\(value)")
                .font(.title3.monospacedDigit().weight(.black))
        }
        .foregroundStyle(DangoTheme.text)
    }
}

#Preview("Clear") {
    ResultView(
        appState: AppState(),
        outcome: .cleared(
            StageResult(
                isStageClear: true,
                perfectCount: 7,
                goodCount: 2,
                missCount: 0,
                wrongCount: 0
            )
        )
    )
}
