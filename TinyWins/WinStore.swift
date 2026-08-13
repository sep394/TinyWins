import Foundation

@MainActor
final class WinStore: ObservableObject {
    @Published private(set) var wins: [Win] = []

    private let storageKey = "tiny-wins.v1"
    private let defaults: UserDefaults
    private let calendar: Calendar

    init(defaults: UserDefaults = .standard, calendar: Calendar = .current) {
        self.defaults = defaults
        self.calendar = calendar
        load()
    }

    var todayWins: [Win] {
        wins.filter { calendar.isDateInToday($0.createdAt) }
    }

    var streak: Int { WinMetrics.streak(for: wins, calendar: calendar) }

    var groupedWins: [(date: Date, wins: [Win])] {
        Dictionary(grouping: wins) { calendar.startOfDay(for: $0.createdAt) }
            .map { ($0.key, $0.value.sorted { $0.createdAt > $1.createdAt }) }
            .sorted { $0.date > $1.date }
    }

    func add(_ text: String) {
        let win = Win(text: text)
        guard !win.text.isEmpty else { return }
        wins.insert(win, at: 0)
        save()
    }

    func delete(_ win: Win) {
        wins.removeAll { $0.id == win.id }
        save()
    }

    private func load() {
        guard let data = defaults.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([Win].self, from: data) else { return }
        wins = decoded.sorted { $0.createdAt > $1.createdAt }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(wins) else { return }
        defaults.set(data, forKey: storageKey)
    }
}
