import SwiftUI

struct CalculatorRow: View {
    let calculator: Calculator

    var body: some View {
        HStack {
            Text(calculator.name)
                .foregroundColor(.white)
            Spacer()
            if calculator.tier == .pro {
                ProBadge()
            }
        }
    }
}

struct CalculatorListView: View {
    @State private var searchText = ""

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
}
