import SwiftUI

enum ThemeMode: String, CaseIterable, Identifiable {
    case dark
    case day
    case system

    var id: String { rawValue }

    var label: String {
        switch self {
        case .dark: return "ダーク"
        case .day: return "デイ"
        case .system: return "システムに連動"
        }
    }

    var preferredColorScheme: ColorScheme? {
        switch self {
        case .dark: return .dark
        case .day: return .light
        case .system: return nil
        }
    }
}

@Observable
final class ThemeStore {
    var mode: ThemeMode {
        didSet { UserDefaults.standard.set(mode.rawValue, forKey: "themeMode") }
    }

    init() {
        let raw = UserDefaults.standard.string(forKey: "themeMode") ?? ThemeMode.system.rawValue
        self.mode = ThemeMode(rawValue: raw) ?? .system
    }
}
