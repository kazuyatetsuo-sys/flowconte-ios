import SwiftUI

struct ProjectDetailView: View {
    @Bindable var project: ProjectItem
    let allContents: [ContentItem]
    let allTagNames: [String]
    @Binding var isEditing: Bool
    var onSelectContent: (ContentItem) -> Void

    @Environment(\.palette) private var palette

    private var filteredContents: [ContentItem] {
        let tags = Set(project.tagNames)
        let matching: [ContentItem]
        if tags.isEmpty {
            matching = allContents
        } else if project.filterMode == "AND" {
            matching = allContents.filter { tags.isSubset(of: Set($0.tagNames)) }
        } else {
            matching = allContents.filter { !tags.isDisjoint(with: Set($0.tagNames)) }
        }
        switch project.sortBy {
        case "title":
            return matching.sorted { $0.title.localizedCompare($1.title) == .orderedAscending }
        case "updatedAt":
            return matching.sorted { $0.updatedAt > $1.updatedAt }
        default:
            return matching.sorted { $0.createdAt > $1.createdAt }
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                memoSection
                Divider().overlay(palette.border)
                contentListSection
            }
            .padding(20)
            .frame(maxWidth: 760, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(palette.bgBase)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "保存" : "編集") {
                    isEditing.toggle()
                }
                .accessibilityIdentifier("projectEditSaveButton")
            }
        }
        .toolbarBackground(palette.bgPanel, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(palette.scheme, for: .navigationBar)
        .background(
            Button("", action: { isEditing.toggle() })
                .keyboardShortcut(.return, modifiers: .command)
                .opacity(0)
        )
    }

    private var header: some View {
        Group {
            if isEditing {
                VStack(alignment: .leading, spacing: 12) {
                    TextField("プロジェクト名", text: $project.name)
                        .font(.title2.weight(.semibold))
                        .textFieldStyle(.plain)
                        .accessibilityIdentifier("projectNameField")
                    TagEditor(tagNames: $project.tagNames, allTagNames: allTagNames)
                    Picker("条件", selection: Binding(
                        get: { ProjectFilterMode(rawValue: project.filterMode) ?? .or },
                        set: { project.filterMode = $0.rawValue }
                    )) {
                        ForEach(ProjectFilterMode.allCases) { mode in
                            Text(mode.label).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("projectFilterModePicker")
                    Picker("並び順", selection: Binding(
                        get: { ProjectSortBy(rawValue: project.sortBy) ?? .createdAt },
                        set: { project.sortBy = $0.rawValue }
                    )) {
                        ForEach(ProjectSortBy.allCases) { sort in
                            Text(sort.label).tag(sort)
                        }
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text(project.name.isEmpty ? "無題のプロジェクト" : project.name)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(palette.textPrimary)
                    if !project.tagNames.isEmpty {
                        WrapChips {
                            ForEach(project.tagNames, id: \.self) { tag in
                                TagChip(name: tag)
                            }
                        }
                    }
                }
            }
        }
    }

    private var memoSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("メモ").font(.caption).foregroundStyle(palette.textTertiary)
            if isEditing {
                TextEditor(text: $project.memo)
                    .frame(minHeight: 100)
                    .padding(8)
                    .background(palette.bgPanel)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else if project.memo.isEmpty {
                Text("メモなし").font(.caption).foregroundStyle(palette.textTertiary)
            } else {
                MarkdownView(text: project.memo)
            }
        }
    }

    private var contentListSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("該当コンテンツ (\(filteredContents.count))")
                .font(.caption)
                .foregroundStyle(palette.textTertiary)
                .accessibilityIdentifier("projectMatchCountLabel")
            ForEach(filteredContents) { item in
                Button {
                    onSelectContent(item)
                } label: {
                    HStack {
                        Text(item.title)
                            .foregroundStyle(palette.textPrimary)
                        Spacer()
                        if item.released {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.caption)
                                .foregroundStyle(palette.accent)
                        }
                    }
                    .padding(10)
                    .background(palette.bgCard)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("projectContentRow_\(item.title)")
            }
        }
    }
}
