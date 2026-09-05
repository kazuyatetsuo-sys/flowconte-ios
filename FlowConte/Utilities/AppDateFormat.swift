import Foundation

enum AppDateFormat {
    private static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone.current
        f.dateFormat = "yyyy-MM-dd HH:mm"
        return f
    }()

    static func string(from date: Date) -> String {
        formatter.string(from: date)
    }
}
