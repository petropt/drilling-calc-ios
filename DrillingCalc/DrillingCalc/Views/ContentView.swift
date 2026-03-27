import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            CalculatorListView()
                .tabItem {
                    Label("Calculators", systemImage: "function")
                }

            FavoritesView()
                .tabItem {
                    Label("Favorites", systemImage: "star.fill")
                }

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(AppTheme.accent)
    }
}

// MARK: - Favorites View

struct FavoritesView: View {
    @AppStorage("favorites") private var favoritesData: Data = Data()

    private var favoriteIDs: Set<String> {
        (try? JSONDecoder().decode(Set<String>.self, from: favoritesData)) ?? []
    }

    private var favoriteCalcs: [Calculator] {
        Calculator.allCases.filter { favoriteIDs.contains($0.rawValue) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if favoriteCalcs.isEmpty {
                    VStack(spacing: AppTheme.spacingLG) {
                        Image(systemName: "star.slash")
                            .font(.system(size: AppTheme.spacing3XL))
                            .foregroundColor(AppTheme.secondaryText)
                        Text("No favorites yet")
                            .font(.headline)
                            .foregroundColor(AppTheme.secondaryText)
                        Text("Swipe right on any calculator to add it here")
                            .font(.caption)
                            .foregroundColor(AppTheme.secondaryText)
                            .multilineTextAlignment(.center)
                    }
                    .padding(AppTheme.spacingXL)
                } else {
                    List(favoriteCalcs) { calc in
                        NavigationLink(destination: CalculatorFormView(calculator: calc)) {
                            CalculatorRow(calculator: calc)
                        }
                        .listRowBackground(AppTheme.cardBackground)
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .background(AppTheme.background)
            .navigationTitle("Favorites")
        }
    }
}

// MARK: - History View

struct HistoryView: View {
    @StateObject private var history = HistoryManager.shared

    private var groupedByDay: [(String, [HistoryEntry])] {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none

        let grouped = Dictionary(grouping: history.entries) { entry in
            formatter.string(from: entry.timestamp)
        }

        return grouped.sorted { a, b in
            // Most recent first
            guard let dateA = history.entries.first(where: { formatter.string(from: $0.timestamp) == a.key })?.timestamp,
                  let dateB = history.entries.first(where: { formatter.string(from: $0.timestamp) == b.key })?.timestamp
            else { return false }
            return dateA > dateB
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if history.entries.isEmpty {
                    VStack(spacing: AppTheme.spacingLG) {
                        Image(systemName: "clock.badge.questionmark")
                            .font(.system(size: AppTheme.spacing3XL))
                            .foregroundColor(AppTheme.secondaryText)
                        Text("No calculations yet")
                            .font(.headline)
                            .foregroundColor(AppTheme.secondaryText)
                        Text("Your calculation results will appear here")
                            .font(.caption)
                            .foregroundColor(AppTheme.secondaryText)
                            .multilineTextAlignment(.center)
                    }
                    .padding(AppTheme.spacingXL)
                } else {
                    List {
                        ForEach(groupedByDay, id: \.0) { day, entries in
                            Section(day) {
                                ForEach(entries) { entry in
                                    HistoryRow(entry: entry)
                                        .listRowBackground(AppTheme.cardBackground)
                                }
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .background(AppTheme.background)
            .navigationTitle("History")
            .toolbar {
                if !history.entries.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Clear") {
                            history.clearAll()
                        }
                        .foregroundColor(AppTheme.accent)
                    }
                }
            }
        }
    }
}

struct HistoryRow: View {
    let entry: HistoryEntry

    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: entry.timestamp)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
            HStack {
                Text(entry.calculatorName)
                    .font(.body.bold())
                    .foregroundColor(.white)
                Spacer()
                Text(timeString)
                    .font(.caption)
                    .foregroundColor(AppTheme.secondaryText)
            }

            ForEach(entry.results) { result in
                HStack(spacing: AppTheme.spacingXS) {
                    Text(result.label)
                        .font(.caption)
                        .foregroundColor(AppTheme.secondaryText)
                    Spacer()
                    Text(result.value)
                        .font(.caption.bold())
                        .foregroundColor(.white)
                    if !result.unit.isEmpty {
                        Text(result.unit)
                            .font(.caption)
                            .foregroundColor(AppTheme.accent)
                    }
                }
            }
        }
        .padding(.vertical, AppTheme.spacingXS)
    }
}
