import SwiftUI

struct MarkdownView: View {
    let text: String
    @Environment(\.palette) private var palette

    private var blocks: [MarkdownBlock] { MarkdownParser.parse(text) }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(blocks) { block in
                blockView(for: block.kind)
            }
        }
    }

    @ViewBuilder
    private func blockView(for kind: MarkdownBlock.Kind) -> some View {
        switch kind {
        case .heading(let level, let text):
            Text(MarkdownParser.inlineAttributed(text))
                .font(headingFont(level))
                .foregroundStyle(palette.textPrimary)
                .padding(.top, level == 1 ? 6 : 2)
        case .paragraph(let text):
            Text(MarkdownParser.inlineAttributed(text))
                .font(.body)
                .foregroundStyle(palette.textBody)
                .lineSpacing(5)
        case .bulletList(let items):
            VStack(alignment: .leading, spacing: 4) {
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: 6) {
                        Text("•").foregroundStyle(palette.textSecondary)
                        Text(MarkdownParser.inlineAttributed(item))
                            .foregroundStyle(palette.textBody)
                    }
                }
            }
        case .numberedList(let items):
            VStack(alignment: .leading, spacing: 4) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    HStack(alignment: .top, spacing: 6) {
                        Text("\(index + 1).").foregroundStyle(palette.textSecondary)
                        Text(MarkdownParser.inlineAttributed(item))
                            .foregroundStyle(palette.textBody)
                    }
                }
            }
        case .blockquote(let text):
            HStack(spacing: 8) {
                Rectangle()
                    .fill(palette.accentLine)
                    .frame(width: 2)
                Text(MarkdownParser.inlineAttributed(text))
                    .foregroundStyle(palette.textSecondary)
                    .italic()
            }
        case .image(let caption, let fileName):
            VStack(alignment: .leading, spacing: 4) {
                if let uiImage = PhotoStorage.loadImage(fileName: fileName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(palette.bgPanel)
                        .frame(height: 120)
                        .overlay(Text("写真が見つかりません").font(.caption).foregroundStyle(palette.textTertiary))
                }
                if !caption.isEmpty {
                    Text(caption)
                        .font(.caption)
                        .foregroundStyle(palette.textTertiary)
                }
            }
        }
    }

    private func headingFont(_ level: Int) -> Font {
        switch level {
        case 1: return .title3.weight(.semibold)
        case 2: return .headline
        default: return .subheadline.weight(.semibold)
        }
    }
}
