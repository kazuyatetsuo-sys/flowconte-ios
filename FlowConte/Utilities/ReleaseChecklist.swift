import Foundation

enum ReleaseRequirement: String, CaseIterable, Identifiable {
    case title
    case bodyLength
    case tag

    var id: String { rawValue }

    var label: String {
        switch self {
        case .title: return "タイトルが設定されていません"
        case .bodyLength: return "本文が30文字未満です"
        case .tag: return "タグが1つも設定されていません"
        }
    }
}

enum ReleaseChecklist {
    static let defaultTitle = "無題のコンテンツ"
    static let minimumBodyLength = 30

    static func missingRequirements(for content: ContentItem) -> [ReleaseRequirement] {
        var missing: [ReleaseRequirement] = []
        let trimmedTitle = content.title.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedTitle.isEmpty || trimmedTitle == defaultTitle {
            missing.append(.title)
        }
        if content.body.count < minimumBodyLength {
            missing.append(.bodyLength)
        }
        if content.tagNames.isEmpty {
            missing.append(.tag)
        }
        return missing
    }

    static func canRelease(_ content: ContentItem) -> Bool {
        missingRequirements(for: content).isEmpty
    }
}
