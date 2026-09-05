import Foundation
import SwiftData

enum TagStore {
    static func allTagNames(contents: [ContentItem], projects: [ProjectItem]) -> [String] {
        var set = Set<String>()
        for content in contents { set.formUnion(content.tagNames) }
        for project in projects { set.formUnion(project.tagNames) }
        return set.sorted { $0.localizedCompare($1) == .orderedAscending }
    }

    static func normalize(_ raw: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let first = trimmed.first else { return trimmed }
        return first.uppercased() + trimmed.dropFirst()
    }

    static func rename(
        from old: String,
        to newRaw: String,
        contents: [ContentItem],
        projects: [ProjectItem]
    ) {
        let newName = normalize(newRaw)
        guard !newName.isEmpty, newName != old else { return }
        for content in contents where content.tagNames.contains(old) {
            content.tagNames = content.tagNames.map { $0 == old ? newName : $0 }
            content.updatedAt = Date()
        }
        for project in projects where project.tagNames.contains(old) {
            project.tagNames = project.tagNames.map { $0 == old ? newName : $0 }
        }
    }

    static func delete(_ name: String, contents: [ContentItem], projects: [ProjectItem]) {
        for content in contents where content.tagNames.contains(name) {
            content.tagNames.removeAll { $0 == name }
            content.updatedAt = Date()
        }
        for project in projects where project.tagNames.contains(name) {
            project.tagNames.removeAll { $0 == name }
        }
    }
}
