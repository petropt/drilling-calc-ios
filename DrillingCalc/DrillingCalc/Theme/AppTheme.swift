import SwiftUI

enum AppTheme {
    static let accent = Color(red: 1.0, green: 0.42, blue: 0.0)       // #FF6B00
    static let background = Color(red: 0.07, green: 0.07, blue: 0.08)  // near black
    static let cardBackground = Color(red: 0.12, green: 0.12, blue: 0.14)
    static let secondaryText = Color(white: 0.70)  // improved contrast for outdoor readability

    static let proBadgeGradient = LinearGradient(
        colors: [Color.orange, Color.red],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let resultBorderGradient = LinearGradient(
        colors: [accent, Color.orange.opacity(0.4), Color.clear],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Rig-floor friendly font sizes
    static let inputLabelFont: Font = .subheadline.weight(.medium)
    static let inputUnitFont: Font = .caption.weight(.medium)
    static let inputValueFont: Font = .body
    static let resultValueFont: Font = .system(.title2, design: .monospaced).bold()
    static let resultLabelFont: Font = .subheadline
}

struct ProBadge: View {
    var body: some View {
        Text("PRO")
            .font(.caption2.bold())
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(AppTheme.proBadgeGradient)
            .cornerRadius(4)
    }
}

struct ResultCard: View {
    let item: ResultItem

    var body: some View {
        HStack {
            Text(item.label)
                .foregroundColor(AppTheme.secondaryText)
                .font(AppTheme.resultLabelFont)
            Spacer()
            HStack(spacing: 4) {
                Text(item.value)
                    .font(AppTheme.resultValueFont)
                    .foregroundColor(AppTheme.accent)
                if !item.unit.isEmpty {
                    Text(item.unit)
                        .font(.caption.weight(.medium))
                        .foregroundColor(AppTheme.secondaryText)
                }
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.resultBorderGradient, lineWidth: 1)
        )
    }
}
