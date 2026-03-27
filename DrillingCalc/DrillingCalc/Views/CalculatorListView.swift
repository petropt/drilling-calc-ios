import SwiftUI

struct CalculatorRow: View {
    let calculator: Calculator

    var body: some View {
        HStack(spacing: AppTheme.spacingMD) {
            Image(systemName: calculator.icon)
                .font(.headline)
                .foregroundColor(calculator.tier == .free ? AppTheme.accent : .gray)
                .frame(width: AppTheme.spacingXXL)

            VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
                Text(calculator.name)
                    .font(.body.weight(.medium))
                    .foregroundColor(.white)
                Text(calculator.shortDescription)
                    .font(.caption)
                    .foregroundColor(AppTheme.secondaryText)
                    .lineLimit(1)
            }

            Spacer()

            if calculator.tier == .pro {
                ProBadge()
            }

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundColor(Color.white.opacity(0.25))
        }
        .padding(.vertical, AppTheme.spacingSM)
    }
}

struct CalculatorListView: View {
    @AppStorage("favorites") private var favoritesData: Data = Data()
    @State private var searchText = ""

    private var favoriteIDs: Set<String> {
        (try? JSONDecoder().decode(Set<String>.self, from: favoritesData)) ?? []
    }

    private var grouped: [(category: CalculatorCategory, calculators: [Calculator])] {
        let allGrouped = Calculator.grouped()
        if searchText.isEmpty { return allGrouped }
        return allGrouped.compactMap { group in
            let filtered = group.calculators.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
            return filtered.isEmpty ? nil : (category: group.category, calculators: filtered)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(grouped, id: \.category.id) { group in
                    Section {
                        ForEach(group.calculators) { calc in
                            NavigationLink(destination: CalculatorFormView(calculator: calc)) {
                                CalculatorRow(calculator: calc)
                            }
                            .listRowBackground(AppTheme.cardBackground)
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button {
                                    toggleFavorite(calc)
                                } label: {
                                    Label(
                                        favoriteIDs.contains(calc.rawValue) ? "Unfavorite" : "Favorite",
                                        systemImage: favoriteIDs.contains(calc.rawValue) ? "star.slash" : "star.fill"
                                    )
                                }
                                .tint(AppTheme.accent)
                            }
                        }
                    } header: {
                        HStack(spacing: AppTheme.spacingSM) {
                            Image(systemName: group.category.icon)
                                .font(.headline)
                            Text(group.category.rawValue.uppercased())
                                .font(.headline)
                                .tracking(1.5)
                        }
                        .foregroundColor(AppTheme.accent)
                        .padding(.top, AppTheme.spacingMD)
                        .padding(.bottom, AppTheme.spacingXS)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.background)
            .navigationTitle("Drilling Calc")
            .searchable(text: $searchText, prompt: "Search calculators")
        }
    }

    private func toggleFavorite(_ calc: Calculator) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        var ids = favoriteIDs
        if ids.contains(calc.rawValue) {
            ids.remove(calc.rawValue)
        } else {
            ids.insert(calc.rawValue)
        }
        favoritesData = (try? JSONEncoder().encode(ids)) ?? Data()
    }
}
