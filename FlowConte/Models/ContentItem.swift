import Foundation
import SwiftData

@Model
final class ContentItem {
    var id: UUID = UUID()
    var title: String = "無題のコンテンツ"
    var body: String = ""
    var tagNames: [String] = []
    var linkedContentIDs: [UUID] = []
    var photoFileName: String?
    var released: Bool = false
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    init(
        id: UUID = UUID(),
        title: String = "無題のコンテンツ",
        body: String = "",
        tagNames: [String] = [],
        linkedContentIDs: [UUID] = [],
        photoFileName: String? = nil,
        released: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.tagNames = tagNames
        self.linkedContentIDs = linkedContentIDs
        self.photoFileName = photoFileName
        self.released = released
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
