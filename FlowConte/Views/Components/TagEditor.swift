import SwiftUI

struct TagEditor: View {
    @Binding var tagNames: [String]
    let allTagNames: [String]

    @State private var draft: String = ""
    @Environment(\.palette) private var palette

    private var suggestions: [String] {
        let lowered = draft.trimmingCharacters(in: .whitespaces).lowercased()
        return allTagNames
            .filter { !tagNames.contains($0) }
            .filter { lowered.isEmpty || $0.lowercased().contains(lowered) }
            .prefix(6)
            .map { $0 }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !tagNames.isEmpty {
                WrapChips {
                    ForEach(tagNames, id: \.self) { tag in
                        TagChip(name: tag, isActive: true) {
                            remove(tag)
                        } onRemove: {
                            remove(tag)
                        }
                    }
                }
            }
            HStack {
                TextField("タグを追加…", text: $draft)
                    .textFieldStyle(.plain)
                    .onSubmit { commitDraft() }
                    .accessibilityIdentifier("tagDraftField")
                Button("追加") { commitDraft() }
                    .disabled(draft.trimmingCharacters(in: .whitespaces).isEmpty)
                    .accessibilityIdentifier("tagAddButton")
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(palette.bgPanel)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            if !suggestions.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(suggestions, id: \.self) { tag in
                            TagChip(name: tag) { add(tag) }
                        }
                    }
                }
            }
        }
    }

    private func commitDraft() {
        let trimmed = draft.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        add(trimmed)
        draft = ""
    }

    private func add(_ raw: String) {
        let normalized = TagStore.normalize(raw)
        guard !normalized.isEmpty, !tagNames.contains(normalized) else { return }
        tagNames.append(normalized)
    }

    private func remove(_ tag: String) {
        tagNames.removeAll { $0 == tag }
    }
}

/// A minimal flow layout so tag chips wrap onto multiple lines instead of clipping.
struct WrapChips: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: maxWidth, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x: CGFloat = bounds.minX
        var y: CGFloat = bounds.minY
        var rowHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
