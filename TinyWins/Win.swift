import Foundation

struct Win: Identifiable, Codable, Equatable {
    let id: UUID
    var text: String
    let createdAt: Date

    init(id: UUID = UUID(), text: String, createdAt: Date = .now) {
        self.id = id
        self.text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        self.createdAt = createdAt
    }
}

enum WinMetrics {
    static func streak(for wins: [Win], calendar: Calendar = .current, now: Date = .now) -> Int {
        let activeDays = Set(wins.map { calendar.startOfDay(for: $0.createdAt) })
        guard !activeDays.isEmpty else { return 0 }

        let today = calendar.startOfDay(for: now)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        guard activeDays.contains(today) || activeDays.contains(yesterday) else { return 0 }

        var day = activeDays.contains(today) ? today : yesterday
        var count = 0
        while activeDays.contains(day) {
            count += 1
            day = calendar.date(byAdding: .day, value: -1, to: day)!
        }
        return count
    }
}
