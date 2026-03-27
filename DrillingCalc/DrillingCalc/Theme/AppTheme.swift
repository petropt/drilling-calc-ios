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

    // MARK: - Typography Hierarchy (max 4 sizes, 2 weights)
    // .title.bold()                           — screen titles only
    // .headline                               — section headers
    // .body                                   — calculator names, labels
    // .caption                                — secondary text, units, descriptions
    // .system(.title2, design: .monospaced)   — result numbers ONLY

    static let inputLabelFont: Font = .body.weight(.medium)
    static let inputUnitFont: Font = .caption.weight(.medium)
    static let inputValueFont: Font = .body
    static let resultValueFont: Font = .system(.title2, design: .monospaced).bold()
    static let resultLabelFont: Font = .body

    // MARK: - 8-Point Grid Spacing Constants
    static let spacingXS: CGFloat = 4
    static let spacingSM: CGFloat = 8
    static let spacingMD: CGFloat = 12
    static let spacingLG: CGFloat = 16
    static let spacingXL: CGFloat = 24
    static let spacingXXL: CGFloat = 32
    static let spacing3XL: CGFloat = 48
    static let spacing4XL: CGFloat = 64
}

struct ProBadge: View {
    var body: some View {
        Text("PRO")
            .font(.caption.bold())
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
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
                    .shadow(color: AppTheme.accent.opacity(0.10), radius: 12, x: 0, y: 0)
                if !item.unit.isEmpty {
                    Text(item.unit)
                        .font(.caption.weight(.medium))
                        .foregroundColor(AppTheme.secondaryText)
                }
            }
        }
        .padding(AppTheme.spacingLG)
        .background(
            ZStack {
                AppTheme.cardBackground
                // Subtle orange glow behind value
                AppTheme.accent.opacity(0.04)
            }
        )
        .cornerRadius(AppTheme.spacingMD)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.spacingMD)
                .stroke(AppTheme.resultBorderGradient, lineWidth: 1)
        )
    }
}

// MARK: - Animated Button Style

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Pro Upgrade Sheet

struct ProUpgradeSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: AppTheme.spacingXL) {
            Spacer()

            Image(systemName: "lock.open.trianglebadge.exclamationmark")
                .font(.system(size: 48))
                .foregroundColor(AppTheme.accent)

            Text("Unlock Pro Calculators")
                .font(.title.bold())
                .foregroundColor(.white)

            Text("Get kill sheets, casing design, and 10 more tools")
                .font(.body)
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)

            Text("$2.99/month")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.top, AppTheme.spacingSM)

            VStack(spacing: AppTheme.spacingMD) {
                Button(action: { dismiss() }) {
                    Text("Subscribe")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppTheme.spacingLG)
                        .background(AppTheme.accent)
                        .cornerRadius(AppTheme.spacingMD)
                }
                .buttonStyle(ScaleButtonStyle())

                Button(action: { dismiss() }) {
                    Text("Maybe Later")
                        .font(.body)
                        .foregroundColor(AppTheme.secondaryText)
                }
            }
            .padding(.horizontal, AppTheme.spacingXL)

            Spacer()
        }
        .padding(AppTheme.spacingXL)
        .background(AppTheme.background.ignoresSafeArea())
    }
}
