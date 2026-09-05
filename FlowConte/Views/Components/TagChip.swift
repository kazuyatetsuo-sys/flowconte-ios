import SwiftUI

struct TagChip: View {
    let name: String
    var isActive: Bool = false
    var onTap: (() -> Void)?
    var onRemove: (() -> Void)?

    @Environment(\.palette) private var palette

    var body: some View {
        HStack(spacing: 4) {
            Text(name)
                .font(.system(.caption, design: .monospaced))
            if let onRemove {
                Button(action: onRemove) {
                    Image(systemName: "xmark")
                        .font(.system(size: 9, weight: .semibold))
                }
                .buttonStyle(.plain)
            }
        }
        .foregroundStyle(isActive ? palette.accent : palette.textSecondary)
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(isActive ? palette.accentSoft : Color.clear)
        )
        .overlay(
            Capsule()
                .stroke(isActive ? palette.accent : palette.accentLine, lineWidth: 1)
        )
        .contentShape(Capsule())
        .onTapGesture { onTap?() }
    }
}
