import SwiftUI

struct ProjectListView: View {
    let projects: [ProjectItem]
    @Binding var selection: UUID?

    @Environment(\.palette) private var palette

    var body: some View {
        List(selection: $selection) {
            ForEach(projects) { project in
                ProjectRow(project: project, isSelected: selection == project.id)
                    .tag(project.id)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12))
                    .focusEffectDisabled()
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(palette.bgBase)
        .paletteAware()
    }
}

private struct ProjectRow: View {
    let project: ProjectItem
    let isSelected: Bool
    @Environment(\.palette) private var palette

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(project.name.isEmpty ? "無題のプロジェクト" : project.name)
                .font(.body.weight(.medium))
                .foregroundStyle(palette.textPrimary)
            if !project.tagNames.isEmpty {
                Text(project.tagNames.joined(separator: project.filterMode == "AND" ? " ∧ " : " ∨ "))
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(palette.textTertiary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(isSelected ? palette.bgCardSelected : palette.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .contentShape(Rectangle())
        .accessibilityIdentifier("projectRow_\(project.name)")
    }
}
