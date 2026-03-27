import SwiftUI

struct SettingsView: View {
    @StateObject private var history = HistoryManager.shared
    @State private var showClearConfirmation = false

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

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

                Section("Data") {
                    HStack {
                        Text("Calculation History")
                            .foregroundColor(.white)
                        Spacer()
                        Text("\(history.entries.count) entries")
                            .foregroundColor(AppTheme.secondaryText)
                    }
                    .listRowBackground(AppTheme.cardBackground)

                    Button(role: .destructive) {
                        showClearConfirmation = true
                    } label: {
                        HStack {
                            Text("Clear History")
                            Spacer()
                            Image(systemName: "trash")
                        }
                    }
                    .disabled(history.entries.isEmpty)
                    .listRowBackground(AppTheme.cardBackground)
                }

                Section("About") {
                    HStack {
                        Text("Version")
                            .foregroundColor(.white)
                        Spacer()
                        Text(appVersion)
                            .font(.caption)
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

                    VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
                        Text("Built by Groundwork Analytics")
                            .foregroundColor(.white)
                        Link("petropt.com", destination: URL(string: "https://petropt.com")!)
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
            .alert("Clear History", isPresented: $showClearConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Clear", role: .destructive) {
                    history.clearAll()
                }
            } message: {
                Text("This will permanently delete all calculation history.")
            }
        }
    }
}
