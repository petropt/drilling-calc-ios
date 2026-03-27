import SwiftUI

struct CalculatorRow: View {
    let calculator: Calculator

    var body: some View {
        HStack {
            Text(calculator.name)
                .font(.body)
                .foregroundColor(.white)
            Spacer()
            if calculator.tier == .pro {
                ProBadge()
            }
        }
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
                        Label(group.category.rawValue, systemImage: group.category.icon)
                            .foregroundColor(AppTheme.accent)
                            .font(.headline)
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
