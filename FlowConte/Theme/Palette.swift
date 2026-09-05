import SwiftUI

struct Palette {
    let bgBase: Color
    let bgPanel: Color
    let bgCard: Color
    let bgCardHover: Color
    let bgCardSelected: Color
    let accent: Color
    let accentSoft: Color
    let accentLine: Color
    let textPrimary: Color
    let textSecondary: Color
    let textTertiary: Color
    let textBody: Color
    let border: Color
    let borderSoft: Color

    static let dark = Palette(
        bgBase: Color(hex: "1b1917"),
        bgPanel: Color(hex: "211e1b"),
        bgCard: Color(hex: "292520"),
        bgCardHover: Color(hex: "332d26"),
        bgCardSelected: Color(hex: "3b2e1c"),
        accent: Color(hex: "c9a24b"),
        accentSoft: Color(hex: "c9a24b", opacity: 0.14),
        accentLine: Color(hex: "c9a24b", opacity: 0.35),
        textPrimary: Color(hex: "ede7db"),
        textSecondary: Color(hex: "a39a8a"),
        textTertiary: Color(hex: "6e675a"),
        textBody: Color(hex: "d9d2c4"),
        border: Color(hex: "38332c"),
        borderSoft: Color(hex: "2c2822")
    )

    static let day = Palette(
        bgBase: Color(hex: "f7f5f0"),
        bgPanel: Color(hex: "f1eee7"),
        bgCard: Color(hex: "ffffff"),
        bgCardHover: Color(hex: "f3f1ea"),
        bgCardSelected: Color(hex: "e9e4d6"),
        accent: Color(hex: "8a7e68"),
        accentSoft: Color(hex: "8a7e68", opacity: 0.1),
        accentLine: Color(hex: "8a7e68", opacity: 0.3),
        textPrimary: Color(hex: "2e2b25"),
        textSecondary: Color(hex: "736c5f"),
        textTertiary: Color(hex: "9c9585"),
        textBody: Color(hex: "48453c"),
        border: Color(hex: "e3ded2"),
        borderSoft: Color(hex: "ece8de")
    )

    static func current(for colorScheme: ColorScheme) -> Palette {
        colorScheme == .dark ? .dark : .day
    }
}

private struct PaletteKey: EnvironmentKey {
    static let defaultValue: Palette = .dark
}

extension EnvironmentValues {
    var palette: Palette {
        get { self[PaletteKey.self] }
        set { self[PaletteKey.self] = newValue }
    }
}

struct PaletteProvider: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    func body(content: Content) -> some View {
        content.environment(\.palette, Palette.current(for: colorScheme))
    }
}

extension View {
    func paletteAware() -> some View {
        modifier(PaletteProvider())
    }
}
