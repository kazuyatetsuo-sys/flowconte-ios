import SwiftUI

struct ProjectListView: View {
    let projects: [ProjectItem]
    @Binding var selection: UUID?

    @Environment(\.palette) private var palette

    var body: some View {
        List(selection: $selection) {
            ForEach(projects) { project in
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
                .padding(.vertical, 4)
                .tag(project.id)
                .listRowBackground(selection == project.id ? palette.bgCardSelected : palette.bgCard)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(palette.bgBase)
    }
}
