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

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
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
                    VStack(spacing: 16) {
                        Image(systemName: "star")
                            .font(.system(size: 48))
                            .foregroundColor(AppTheme.secondaryText)
                        Text("No favorites yet")
                            .foregroundColor(AppTheme.secondaryText)
                        Text("Tap the star icon on any calculator to save it here.")
                            .font(.caption)
                            .foregroundColor(AppTheme.secondaryText)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
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
