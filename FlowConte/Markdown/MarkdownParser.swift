import Foundation

struct MarkdownBlock: Identifiable {
    enum Kind {
        case heading(level: Int, text: String)
        case paragraph(text: String)
        case bulletList(items: [String])
        case numberedList(items: [String])
        case blockquote(text: String)
        case image(caption: String, fileName: String)
    }

    let id = UUID()
    let kind: Kind
}

enum MarkdownParser {
    private static let imageRegex = try! NSRegularExpression(pattern: #"^!\[(.*?)\]\((.*?)\)$"#)
    private static let numberedRegex = try! NSRegularExpression(pattern: #"^\d+\.\s+(.*)$"#)

    static func parse(_ text: String) -> [MarkdownBlock] {
        var blocks: [MarkdownBlock] = []
        var bulletBuffer: [String] = []
        var numberBuffer: [String] = []

        func flushBullets() {
            if !bulletBuffer.isEmpty {
                blocks.append(MarkdownBlock(kind: .bulletList(items: bulletBuffer)))
                bulletBuffer = []
            }
        }
        func flushNumbers() {
            if !numberBuffer.isEmpty {
                blocks.append(MarkdownBlock(kind: .numberedList(items: numberBuffer)))
                numberBuffer = []
            }
        }

        let lines = text.components(separatedBy: .newlines)
        for rawLine in lines {
            let line = rawLine.trimmingCharacters(in: .whitespaces)

            if line.isEmpty {
                flushBullets()
                flushNumbers()
                continue
            }

            if let match = imageRegex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
               let captionRange = Range(match.range(at: 1), in: line),
               let targetRange = Range(match.range(at: 2), in: line) {
                flushBullets()
                flushNumbers()
                blocks.append(MarkdownBlock(kind: .image(
                    caption: String(line[captionRange]),
                    fileName: String(line[targetRange])
                )))
                continue
            }

            if line.hasPrefix("### ") {
                flushBullets(); flushNumbers()
                blocks.append(MarkdownBlock(kind: .heading(level: 3, text: String(line.dropFirst(4)))))
                continue
            }
            if line.hasPrefix("## ") {
                flushBullets(); flushNumbers()
                blocks.append(MarkdownBlock(kind: .heading(level: 2, text: String(line.dropFirst(3)))))
                continue
            }
            if line.hasPrefix("# ") {
                flushBullets(); flushNumbers()
                blocks.append(MarkdownBlock(kind: .heading(level: 1, text: String(line.dropFirst(2)))))
                continue
            }

            if line.hasPrefix("> ") {
                flushBullets(); flushNumbers()
                blocks.append(MarkdownBlock(kind: .blockquote(text: String(line.dropFirst(2)))))
                continue
            }

            if line.hasPrefix("- ") || line.hasPrefix("* ") {
                flushNumbers()
                bulletBuffer.append(String(line.dropFirst(2)))
                continue
            }

            if let match = numberedRegex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
               let itemRange = Range(match.range(at: 1), in: line) {
                flushBullets()
                numberBuffer.append(String(line[itemRange]))
                continue
            }

            flushBullets()
            flushNumbers()
            blocks.append(MarkdownBlock(kind: .paragraph(text: line)))
        }

        flushBullets()
        flushNumbers()
        return blocks
    }

    /// Converts `**bold**` spans within a line of inline text into an AttributedString.
    static func inlineAttributed(_ text: String) -> AttributedString {
        var result = AttributedString()
        var remainder = Substring(text)
        while let range = remainder.range(of: "**") {
            let before = remainder[remainder.startIndex..<range.lowerBound]
            result += AttributedString(before)
            let afterOpen = remainder[range.upperBound...]
            guard let closeRange = afterOpen.range(of: "**") else {
                result += AttributedString("**")
                remainder = afterOpen
                break
            }
            var bold = AttributedString(afterOpen[afterOpen.startIndex..<closeRange.lowerBound])
            bold.font = .body.bold()
            result += bold
            remainder = afterOpen[closeRange.upperBound...]
        }
        result += AttributedString(remainder)
        return result
    }
}
