import XCTest
@testable import TinyWins

final class TinyWinsTests: XCTestCase {
    func testWinTrimsWhitespace() {
        XCTAssertEqual(Win(text: "  Sent the email  ").text, "Sent the email")
    }

    func testStreakCountsConsecutiveDays() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        let wins = [0, -1, -2].map { offset in
            Win(text: "Win", createdAt: calendar.date(byAdding: .day, value: offset, to: now)!)
        }
        XCTAssertEqual(WinMetrics.streak(for: wins, calendar: calendar, now: now), 3)
    }

    func testStreakAllowsYesterdayAsMostRecentDay() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        XCTAssertEqual(WinMetrics.streak(for: [Win(text: "Win", createdAt: yesterday)], calendar: calendar, now: now), 1)
    }
}
