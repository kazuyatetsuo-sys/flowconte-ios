import SwiftUI

struct RelatedContentEditor: View {
    @Binding var linkedContentIDs: [UUID]
    let excludingID: UUID
    let allContents: [ContentItem]
    var onSelect: ((ContentItem) -> Void)?

    @State private var query: String = ""
    @State private var isFocused: Bool = false
    @Environment(\.palette) private var palette

    private var linkedContents: [ContentItem] {
        linkedContentIDs.compactMap { id in allContents.first { $0.id == id } }
    }

    private var suggestions: [ContentItem] {
        let pool = allContents
            .filter { $0.id != excludingID && !linkedContentIDs.contains($0.id) }
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            return Array(pool.sorted { $0.updatedAt > $1.updatedAt }.prefix(5))
        }
        return Array(pool.filter { $0.title.localizedCaseInsensitiveContains(trimmed) }.prefix(8))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !linkedContents.isEmpty {
                WrapChips {
                    ForEach(linkedContents) { item in
                        TagChip(name: item.title, isActive: true) {
                            onSelect?(item)
                        } onRemove: {
                            linkedContentIDs.removeAll { $0 == item.id }
                        }
                    }
                }
            }
            TextField("関連コンテンツを検索…", text: $query, onEditingChanged: { editing in
                isFocused = editing
            })
            .textFieldStyle(.plain)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(palette.bgPanel)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            if isFocused || !query.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(suggestions) { item in
                        Button {
                            linkedContentIDs.append(item.id)
                            query = ""
                        } label: {
                            HStack {
                                Text(item.title)
                                    .foregroundStyle(palette.textPrimary)
                                Spacer()
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .background(palette.bgPanel)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}
