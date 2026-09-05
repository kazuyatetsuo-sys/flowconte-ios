import SwiftUI
import SwiftData

enum SidebarTab: String, CaseIterable, Identifiable {
    case all = "すべて"
    case projects = "プロジェクト"
    var id: String { rawValue }
}

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.palette) private var palette

    @Query(sort: \ContentItem.createdAt, order: .reverse) private var allContents: [ContentItem]
    @Query(sort: \ProjectItem.createdAt, order: .reverse) private var allProjects: [ProjectItem]

    @State private var tab: SidebarTab = .all
    @State private var selectedContentID: UUID?
    @State private var selectedProjectID: UUID?
    @State private var tagFilters: Set<String> = []
    @State private var isEditingDetail = false
    @State private var writingMode = false
    @State private var pendingEditID: UUID?
    @State private var showingSettings = false
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    private var allTagNames: [String] {
        TagStore.allTagNames(contents: allContents, projects: allProjects)
    }

    private var filteredContents: [ContentItem] {
        guard !tagFilters.isEmpty else { return allContents }
        return allContents.filter { !tagFilters.isDisjoint(with: Set($0.tagNames)) }
    }

    private var selectedContent: ContentItem? {
        allContents.first { $0.id == selectedContentID }
    }

    private var selectedProject: ProjectItem? {
        allProjects.first { $0.id == selectedProjectID }
    }

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            sidebar
        } detail: {
            NavigationStack {
                detail
            }
        }
        .paletteAware()
        .background(
            Button("", action: createNewContent)
                .keyboardShortcut(.return, modifiers: [.command, .control])
                .opacity(0)
        )
        .onChange(of: writingMode) { _, newValue in
            columnVisibility = newValue ? .detailOnly : .all
        }
        .onChange(of: selectedContentID) { _, _ in isEditingDetail = false }
        .onChange(of: selectedProjectID) { _, _ in isEditingDetail = false }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }

    @ViewBuilder
    private var sidebar: some View {
        VStack(spacing: 0) {
            if !writingMode {
                Picker("タブ", selection: $tab) {
                    ForEach(SidebarTab.allCases) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 12)
                .padding(.top, 8)

                if tab == .all {
                    TagFilterBar(allTags: allTagNames, selectedTags: $tagFilters)
                }
            }

            switch tab {
            case .all:
                ContentListView(
                    contents: filteredContents,
                    selection: $selectedContentID,
                    isEditingDetail: isEditingDetail,
                    onMoveUp: { moveSelection(offset: -1) },
                    onMoveDown: { moveSelection(offset: 1) }
                )
            case .projects:
                ProjectListView(projects: allProjects, selection: $selectedProjectID)
            }
        }
        .background(palette.bgBase)
        .navigationTitle("FlowConte")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    if tab == .all { createNewContent() } else { createNewProject() }
                } label: {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingSettings = true
                } label: {
                    Image(systemName: "gearshape")
                }
            }
        }
    }

    @ViewBuilder
    private var detail: some View {
        switch tab {
        case .all:
            if let content = selectedContent {
                ContentDetailView(
                    content: content,
                    allContents: allContents,
                    allTagNames: allTagNames,
                    isEditing: $isEditingDetail,
                    writingMode: $writingMode,
                    onNavigate: { navigateTo($0) }
                )
                .id(content.id)
                .onAppear { activatePendingEdit(for: content.id) }
            } else {
                placeholder("コンテンツを選択してください")
            }
        case .projects:
            if let project = selectedProject {
                ProjectDetailView(
                    project: project,
                    allContents: allContents,
                    allTagNames: allTagNames,
                    isEditing: $isEditingDetail,
                    onSelectContent: { navigateTo($0) }
                )
                .id(project.id)
                .onAppear { activatePendingEdit(for: project.id) }
            } else {
                placeholder("プロジェクトを選択してください")
            }
        }
    }

    private func placeholder(_ text: String) -> some View {
        Text(text)
            .foregroundStyle(palette.textTertiary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(palette.bgBase)
    }

    private func navigateTo(_ content: ContentItem) {
        tab = .all
        selectedContentID = content.id
    }

    private func activatePendingEdit(for id: UUID) {
        if pendingEditID == id {
            isEditingDetail = true
            pendingEditID = nil
        }
    }

    private func createNewContent() {
        let item = ContentItem()
        modelContext.insert(item)
        tab = .all
        selectedContentID = item.id
        pendingEditID = item.id
    }

    private func createNewProject() {
        let project = ProjectItem()
        modelContext.insert(project)
        tab = .projects
        selectedProjectID = project.id
        pendingEditID = project.id
    }

    private func moveSelection(offset: Int) {
        guard !filteredContents.isEmpty else { return }
        guard let currentID = selectedContentID,
              let index = filteredContents.firstIndex(where: { $0.id == currentID }) else {
            selectedContentID = filteredContents.first?.id
            return
        }
        let newIndex = index + offset
        guard filteredContents.indices.contains(newIndex) else { return }
        selectedContentID = filteredContents[newIndex].id
    }
}
