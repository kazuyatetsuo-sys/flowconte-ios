import SwiftUI
import SwiftData

struct ContentListView: View {
    let contents: [ContentItem]
    @Binding var selection: UUID?
    let isEditingDetail: Bool
    let onMoveUp: () -> Void
    let onMoveDown: () -> Void

    @Environment(\.palette) private var palette

    var body: some View {
        ZStack {
            List(selection: $selection) {
                ForEach(contents) { item in
                    ContentRow(item: item, isSelected: selection == item.id)
                        .tag(item.id)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12))
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(palette.bgBase)

            Button("", action: onMoveUp)
                .keyboardShortcut(.upArrow, modifiers: [])
                .opacity(0)
                .frame(width: 0, height: 0)
                .disabled(isEditingDetail)
            Button("", action: onMoveDown)
                .keyboardShortcut(.downArrow, modifiers: [])
                .opacity(0)
                .frame(width: 0, height: 0)
                .disabled(isEditingDetail)
        }
    }
}

private struct ContentRow: View {
    let item: ContentItem
    let isSelected: Bool
    @Environment(\.palette) private var palette

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(item.title)
                    .font(.body.weight(.medium))
                    .foregroundStyle(palette.textPrimary)
                    .lineLimit(1)
                Spacer()
                if item.released {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.caption)
                        .foregroundStyle(palette.accent)
                }
            }
            if !item.body.isEmpty {
                Text(item.body)
                    .font(.caption)
                    .foregroundStyle(palette.textSecondary)
                    .lineLimit(2)
            }
            HStack(spacing: 6) {
                Text(AppDateFormat.string(from: item.updatedAt))
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(palette.textTertiary)
                ForEach(item.tagNames.prefix(3), id: \.self) { tag in
                    Text(tag)
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundStyle(palette.textTertiary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(isSelected ? palette.bgCardSelected : palette.bgCard)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? palette.accentLine : Color.clear, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .contentShape(Rectangle())
        .accessibilityIdentifier("contentRow_\(item.title)")
    }
}
