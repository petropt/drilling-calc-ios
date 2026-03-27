import Foundation

struct HistoryEntry: Identifiable, Codable {
    let id: UUID
    let calculatorID: String
    let calculatorName: String
    let inputs: [String: String]
    let results: [HistoryResult]
    let timestamp: Date

    init(calculatorID: String, calculatorName: String, inputs: [String: String], results: [HistoryResult]) {
        self.id = UUID()
        self.calculatorID = calculatorID
        self.calculatorName = calculatorName
        self.inputs = inputs
        self.results = results
        self.timestamp = Date()
    }
}

struct HistoryResult: Identifiable, Codable {
    let id: UUID
    let label: String
    let value: String
    let unit: String

    init(label: String, value: String, unit: String) {
        self.id = UUID()
        self.label = label
        self.value = value
        self.unit = unit
    }

    init(from resultItem: ResultItem) {
        self.id = UUID()
        self.label = resultItem.label
        self.value = resultItem.value
        self.unit = resultItem.unit
    }
}

final class HistoryManager: ObservableObject {
    static let shared = HistoryManager()

    private let key = "calculationHistory"
    private let maxEntries = 50

    @Published var entries: [HistoryEntry] = []

    private init() {
        load()
    }

    func add(calculatorID: String, calculatorName: String, inputs: [String: String], results: [ResultItem]) {
        // Don't save error results
        if results.first?.label == "Error" { return }

        let historyResults = results.map { HistoryResult(from: $0) }
        let entry = HistoryEntry(
            calculatorID: calculatorID,
            calculatorName: calculatorName,
            inputs: inputs,
            results: historyResults
        )

        entries.insert(entry, at: 0)

        // Cap history size
        if entries.count > maxEntries {
            entries = Array(entries.prefix(maxEntries))
        }

        save()
    }

    func clearAll() {
        entries.removeAll()
        save()
    }

    private func save() {
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([HistoryEntry].self, from: data) else { return }
        entries = decoded
    }
}
