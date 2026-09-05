import SwiftUI

struct ProjectListView: View {
    let projects: [ProjectItem]
    @Binding var selection: UUID?

    @Environment(\.palette) private var palette

    var body: some View {
        ZStack {
            palette.bgBase.ignoresSafeArea()

            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(projects) { project in
                        Button {
                            selection = project.id
                        } label: {
                            ProjectRow(project: project, isSelected: selection == project.id)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(12)
            }
        }
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
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? palette.accentLine : Color.clear, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
