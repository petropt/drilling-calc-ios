import SwiftUI

enum AppTheme {
    static let accent = Color(red: 1.0, green: 0.42, blue: 0.0)       // #FF6B00
    static let background = Color(red: 0.07, green: 0.07, blue: 0.08)  // near black
    static let cardBackground = Color(red: 0.12, green: 0.12, blue: 0.14)
    static let secondaryText = Color(white: 0.55)

    static let proBadgeGradient = LinearGradient(
        colors: [Color.orange, Color.red],
        startPoint: .leading,
        endPoint: .trailing
    )
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
                .font(.subheadline)
            Spacer()
            HStack(spacing: 4) {
                Text(item.value)
                    .font(.title2.bold())
                    .foregroundColor(.white)
                if !item.unit.isEmpty {
                    Text(item.unit)
                        .font(.caption)
                        .foregroundColor(AppTheme.accent)
                }
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(12)
    }
}
