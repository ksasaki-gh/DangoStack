//
//  DangoGenerator.swift
//  DangoStack
//

struct DangoGenerator {
    func generateCurrentColor(requiredColors: [DangoColor?]) -> DangoColor? {
        availableColors(in: requiredColors).randomElement()
    }

    func generateSafeNextColor(
        currentColor: DangoColor,
        requiredColors: [DangoColor?]
    ) -> DangoColor? {
        let validSkewerIndices = requiredColors.indices.filter {
            requiredColors[$0] == currentColor
        }

        guard !validSkewerIndices.isEmpty else {
            return generateCurrentColor(requiredColors: requiredColors)
        }

        let colorsAfterSuccessfulPlacements = validSkewerIndices.map { skewerIndex in
            var simulatedRequiredColors = requiredColors
            simulatedRequiredColors[skewerIndex] = colorAfterPlacing(currentColor)
            return Set(availableColors(in: simulatedRequiredColors))
        }

        let nonClearColorSets = colorsAfterSuccessfulPlacements.filter { !$0.isEmpty }
        guard var safeColors = nonClearColorSets.first else {
            return nil
        }

        for colorSet in nonClearColorSets.dropFirst() {
            safeColors.formIntersection(colorSet)
        }

        let fallbackColors = nonClearColorSets.first ?? []

        return DangoColor.allCases
            .filter { safeColors.contains($0) }
            .randomElement()
            ?? DangoColor.allCases
                .filter { fallbackColors.contains($0) }
                .randomElement()
    }

    private func availableColors(in requiredColors: [DangoColor?]) -> [DangoColor] {
        let colorSet = Set(requiredColors.compactMap { $0 })
        return DangoColor.allCases.filter { colorSet.contains($0) }
    }

    private func colorAfterPlacing(_ color: DangoColor) -> DangoColor? {
        switch color {
        case .green:
            return .white
        case .white:
            return .pink
        case .pink:
            return nil
        }
    }
}
