import SwiftUI
import SwiftData
import PhotosUI

struct ContentDetailView: View {
    @Bindable var content: ContentItem
    let allContents: [ContentItem]
    let allTagNames: [String]
    @Binding var isEditing: Bool
    @Binding var writingMode: Bool
    var onNavigate: (ContentItem) -> Void

    @Environment(\.palette) private var palette
    @Environment(\.modelContext) private var modelContext

    @State private var showingMissingRequirements = false
    @State private var photoPickerItem: PhotosPickerItem?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                if !writingMode {
                    metaRow
                }
                bodySection
                if isEditing, !writingMode {
                    photoInsertRow
                }
                if !writingMode {
                    tagSection
                    relatedSection
                    releaseSection
                }
            }
            .padding(20)
        }
        .background(palette.bgBase)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    writingMode.toggle()
                } label: {
                    Image(systemName: writingMode ? "pencil.and.list.clipboard" : "text.alignleft")
                }
                Button(isEditing ? "保存" : "編集") {
                    toggleEditing()
                }
                .accessibilityIdentifier("editSaveButton")
            }
        }
        .toolbar(writingMode ? .hidden : .visible, for: .navigationBar)
        .overlay(alignment: .topTrailing) {
            if writingMode {
                Button {
                    writingMode = false
                } label: {
                    Image(systemName: "arrow.down.right.and.arrow.up.left")
                        .padding(10)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .padding()
            }
        }
        .background(
            Button("", action: toggleEditing)
                .keyboardShortcut(.return, modifiers: .command)
                .opacity(0)
        )
        .alert("リリースの条件が未達です", isPresented: $showingMissingRequirements) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(ReleaseChecklist.missingRequirements(for: content).map(\.label).joined(separator: "\n"))
        }
    }

    private var header: some View {
        Group {
            if isEditing {
                TextField("タイトル", text: $content.title)
                    .font(.title2.weight(.semibold))
                    .textFieldStyle(.plain)
                    .accessibilityIdentifier("contentTitleField")
            } else {
                Text(content.title)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(palette.textPrimary)
            }
        }
    }

    private var metaRow: some View {
        HStack(spacing: 12) {
            Text("作成 \(AppDateFormat.string(from: content.createdAt))")
            Text("更新 \(AppDateFormat.string(from: content.updatedAt))")
        }
        .font(.system(.caption, design: .monospaced))
        .foregroundStyle(palette.textTertiary)
    }

    private var bodySection: some View {
        Group {
            if isEditing {
                TextEditor(text: $content.body)
                    .frame(minHeight: writingMode ? 500 : 220)
                    .padding(8)
                    .background(palette.bgPanel)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .font(.body)
                    .foregroundStyle(palette.textBody)
                    .accessibilityIdentifier("contentBodyEditor")
            } else {
                MarkdownView(text: content.body)
            }
        }
    }

    private var photoInsertRow: some View {
        HStack {
            PhotosPicker(selection: $photoPickerItem, matching: .images) {
                Label("写真を挿入", systemImage: "photo.on.rectangle")
                    .font(.caption)
            }
        }
        .onChange(of: photoPickerItem) { _, newValue in
            guard let newValue else { return }
            Task { await insertPhoto(from: newValue) }
        }
    }

    private var tagSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("タグ").font(.caption).foregroundStyle(palette.textTertiary)
            if isEditing {
                TagEditor(tagNames: $content.tagNames, allTagNames: allTagNames)
            } else if content.tagNames.isEmpty {
                Text("タグなし").font(.caption).foregroundStyle(palette.textTertiary)
            } else {
                WrapChips {
                    ForEach(content.tagNames, id: \.self) { tag in
                        TagChip(name: tag)
                    }
                }
            }
        }
    }

    private var relatedSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("関連コンテンツ").font(.caption).foregroundStyle(palette.textTertiary)
            if isEditing {
                RelatedContentEditor(
                    linkedContentIDs: $content.linkedContentIDs,
                    excludingID: content.id,
                    allContents: allContents
                )
            } else {
                let linked = content.linkedContentIDs.compactMap { id in allContents.first { $0.id == id } }
                if linked.isEmpty {
                    Text("関連コンテンツなし").font(.caption).foregroundStyle(palette.textTertiary)
                } else {
                    WrapChips {
                        ForEach(linked) { item in
                            TagChip(name: item.title) {
                                onNavigate(item)
                            }
                        }
                    }
                }
            }
        }
    }

    private var releaseSection: some View {
        let missing = ReleaseChecklist.missingRequirements(for: content)
        return HStack {
            Button {
                if content.released {
                    content.released = false
                    content.updatedAt = Date()
                } else if missing.isEmpty {
                    content.released = true
                    content.updatedAt = Date()
                } else {
                    showingMissingRequirements = true
                }
            } label: {
                Label(content.released ? "リリース済み" : "未リリース", systemImage: content.released ? "checkmark.seal.fill" : "seal")
            }
            .buttonStyle(.borderedProminent)
            .tint(content.released ? palette.accent : palette.border)
            .accessibilityIdentifier("releaseButton")
        }
    }

    private func toggleEditing() {
        if isEditing {
            content.updatedAt = Date()
        }
        isEditing.toggle()
    }

    private func insertPhoto(from item: PhotosPickerItem) async {
        guard let data = try? await item.loadTransferable(type: Data.self),
              let uiImage = UIImage(data: data) else { return }
        PhotoStorage.saveOriginalToPhotoLibrary(uiImage)
        guard let fileName = try? PhotoStorage.saveCompressed(uiImage) else { return }
        await MainActor.run {
            content.body += "\n![](\(fileName))\n"
            content.photoFileName = fileName
            photoPickerItem = nil
        }
    }
}
