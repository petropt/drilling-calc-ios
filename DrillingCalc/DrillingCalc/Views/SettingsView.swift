import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Units") {
                    HStack {
                        Text("System")
                            .foregroundColor(.white)
                        Spacer()
                        Text("Oilfield (Imperial)")
                            .foregroundColor(AppTheme.secondaryText)
                    }
                    .listRowBackground(AppTheme.cardBackground)
                }

                Section("About") {
                    HStack {
                        Text("Version")
                            .foregroundColor(.white)
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(AppTheme.secondaryText)
                    }
                    .listRowBackground(AppTheme.cardBackground)

                    HStack {
                        Text("Calculators")
                            .foregroundColor(.white)
                        Spacer()
                        Text("\(Calculator.allCases.count)")
                            .foregroundColor(AppTheme.secondaryText)
                    }
                    .listRowBackground(AppTheme.cardBackground)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Built by Groundwork Analytics")
                            .foregroundColor(.white)
                        Link("groundworkanalytics.com", destination: URL(string: "https://groundworkanalytics.com")!)
                            .font(.caption)
                            .foregroundColor(AppTheme.accent)
                    }
                    .listRowBackground(AppTheme.cardBackground)
                }

                Section("Legal") {
                    Text("All calculations are provided for reference only. Always verify results with independent methods before making operational decisions.")
                        .font(.caption)
                        .foregroundColor(AppTheme.secondaryText)
                        .listRowBackground(AppTheme.cardBackground)
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.background)
            .navigationTitle("Settings")
        }
    }
}
