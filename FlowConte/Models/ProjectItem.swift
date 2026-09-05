import Foundation
import SwiftData

enum ProjectFilterMode: String, CaseIterable, Identifiable {
    case and = "AND"
    case or = "OR"
    var id: String { rawValue }
    var label: String { self == .and ? "すべて一致 (AND)" : "いずれか一致 (OR)" }
}

enum ProjectSortBy: String, CaseIterable, Identifiable {
    case createdAt
    case updatedAt
    case title
    var id: String { rawValue }
    var label: String {
        switch self {
        case .createdAt: return "作成日"
        case .updatedAt: return "更新日"
        case .title: return "タイトル"
        }
    }
}

@Model
final class ProjectItem {
    var id: UUID = UUID()
    var name: String = ""
    var tagNames: [String] = []
    var filterMode: String = "OR"
    var sortBy: String = "createdAt"
    var memo: String = ""
    var createdAt: Date = Date()

    init(
        id: UUID = UUID(),
        name: String = "",
        tagNames: [String] = [],
        filterMode: String = "OR",
        sortBy: String = "createdAt",
        memo: String = "",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.tagNames = tagNames
        self.filterMode = filterMode
        self.sortBy = sortBy
        self.memo = memo
        self.createdAt = createdAt
    }
}
