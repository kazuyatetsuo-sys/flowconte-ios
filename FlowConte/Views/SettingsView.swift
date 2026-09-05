import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.palette) private var palette
    @Environment(ThemeStore.self) private var themeStore

    @Query private var contents: [ContentItem]
    @Query private var projects: [ProjectItem]

    @State private var renamingTag: String?
    @State private var renameDraft: String = ""

    private var allTags: [String] {
        TagStore.allTagNames(contents: contents, projects: projects)
    }

    var body: some View {
        @Bindable var themeStore = themeStore
        NavigationStack {
            List {
                Section("テーマ") {
                    Picker("テーマ", selection: $themeStore.mode) {
                        ForEach(ThemeMode.allCases) { mode in
                            Text(mode.label).tag(mode)
                        }
                    }
                    .pickerStyle(.inline)
                }

                Section("タグ管理") {
                    if allTags.isEmpty {
                        Text("タグはまだありません")
                            .foregroundStyle(palette.textTertiary)
                    }
                    ForEach(allTags, id: \.self) { tag in
                        HStack {
                            if renamingTag == tag {
                                TextField("タグ名", text: $renameDraft, onCommit: {
                                    commitRename(from: tag)
                                })
                                .textFieldStyle(.plain)
                            } else {
                                Text(tag)
                                    .onTapGesture {
                                        renamingTag = tag
                                        renameDraft = tag
                                    }
                            }
                            Spacer()
                            Button(role: .destructive) {
                                TagStore.delete(tag, contents: contents, projects: projects)
                            } label: {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .navigationTitle("設定")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
    }

    private func commitRename(from old: String) {
        TagStore.rename(from: old, to: renameDraft, contents: contents, projects: projects)
        renamingTag = nil
    }
}
