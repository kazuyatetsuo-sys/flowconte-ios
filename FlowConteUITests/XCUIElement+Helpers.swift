import XCTest

extension XCUIElement {
    /// Clears whatever text is currently in the field and types `text` instead.
    /// Relies on a plain `tap()` placing the caret at the end of the existing
    /// text (true for the short single-line fields this app uses), then sends
    /// exactly enough backspaces to delete it before typing the replacement.
    func replaceText(with text: String) {
        tap()
        if let current = value as? String, !current.isEmpty {
            typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: current.count))
        }
        typeText(text)
    }
}
