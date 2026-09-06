import SwiftUI
import UIKit

/// A UITextView-backed editor that live-styles raw markdown as the user types
/// (headings colored/sized, `**bold**` spans bolded) while still storing and
/// binding to the plain markdown string. `TextEditor(text: Binding<AttributedString>)`
/// would be the SwiftUI-native way to do this, but it requires iOS 26+; this
/// view keeps the app's iOS 17 minimum deployment target. Styling is built
/// directly with UIFont/UIColor rather than bridging a SwiftUI `AttributedString`,
/// since that bridging does not reliably carry SwiftUI-scoped font/color
/// attributes into `NSAttributedString`.
struct MarkdownTextEditor: UIViewRepresentable {
    @Binding var text: String
    let palette: Palette

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.attributedText = Self.styledText(text, palette: palette)
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        context.coordinator.palette = palette
        guard uiView.text != text else { return }
        let selectedRange = uiView.selectedRange
        uiView.attributedText = Self.styledText(text, palette: palette)
        uiView.selectedRange = selectedRange
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, palette: palette)
    }

    static func styledText(_ text: String, palette: Palette) -> NSAttributedString {
        let bodyFont = UIFont.preferredFont(forTextStyle: .body)
        let bodyColor = UIColor(palette.textBody)
        let result = NSMutableAttributedString()
        let lines = text.components(separatedBy: "\n")

        for (index, line) in lines.enumerated() {
            let lineAttributed: NSMutableAttributedString
            if line.hasPrefix("### ") {
                lineAttributed = NSMutableAttributedString(string: line, attributes: [
                    .font: UIFont.preferredFont(forTextStyle: .subheadline).withWeight(.semibold),
                    .foregroundColor: UIColor(palette.textPrimary)
                ])
            } else if line.hasPrefix("## ") {
                lineAttributed = NSMutableAttributedString(string: line, attributes: [
                    .font: UIFont.preferredFont(forTextStyle: .headline),
                    .foregroundColor: UIColor(palette.accent)
                ])
            } else if line.hasPrefix("# ") {
                lineAttributed = NSMutableAttributedString(string: line, attributes: [
                    .font: UIFont.preferredFont(forTextStyle: .title3).withWeight(.semibold),
                    .foregroundColor: UIColor(palette.textPrimary)
                ])
            } else if line.hasPrefix("> ") {
                lineAttributed = applyingInlineBold(to: line, font: bodyFont, color: UIColor(palette.textSecondary))
            } else {
                lineAttributed = applyingInlineBold(to: line, font: bodyFont, color: bodyColor)
            }
            result.append(lineAttributed)
            if index < lines.count - 1 {
                result.append(NSAttributedString(string: "\n", attributes: [.font: bodyFont, .foregroundColor: bodyColor]))
            }
        }
        return result
    }

    /// Renders `**bold**` spans in bold within an otherwise plain line.
    private static func applyingInlineBold(to line: String, font: UIFont, color: UIColor) -> NSMutableAttributedString {
        let result = NSMutableAttributedString()
        var remainder = Substring(line)
        while let range = remainder.range(of: "**") {
            let before = remainder[remainder.startIndex..<range.lowerBound]
            result.append(NSAttributedString(string: String(before), attributes: [.font: font, .foregroundColor: color]))
            let afterOpen = remainder[range.upperBound...]
            guard let closeRange = afterOpen.range(of: "**") else {
                result.append(NSAttributedString(string: "**", attributes: [.font: font, .foregroundColor: color]))
                remainder = afterOpen
                break
            }
            let boldText = String(afterOpen[afterOpen.startIndex..<closeRange.lowerBound])
            result.append(NSAttributedString(string: boldText, attributes: [.font: font.withWeight(.bold), .foregroundColor: color]))
            remainder = afterOpen[closeRange.upperBound...]
        }
        result.append(NSAttributedString(string: String(remainder), attributes: [.font: font, .foregroundColor: color]))
        return result
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        var text: Binding<String>
        var palette: Palette

        init(text: Binding<String>, palette: Palette) {
            self.text = text
            self.palette = palette
        }

        func textViewDidChange(_ textView: UITextView) {
            let selectedRange = textView.selectedRange
            text.wrappedValue = textView.text
            textView.attributedText = MarkdownTextEditor.styledText(textView.text, palette: palette)
            textView.selectedRange = selectedRange
        }
    }
}

private extension UIFont {
    func withWeight(_ weight: UIFont.Weight) -> UIFont {
        var traits = fontDescriptor.fontAttributes[.traits] as? [UIFontDescriptor.TraitKey: Any] ?? [:]
        traits[.weight] = weight
        let descriptor = fontDescriptor.addingAttributes([.traits: traits])
        return UIFont(descriptor: descriptor, size: pointSize)
    }
}
