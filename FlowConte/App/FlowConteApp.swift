import SwiftUI
import SwiftData

@main
struct FlowConteApp: App {
    @State private var themeStore = ThemeStore()

    var container: ModelContainer = {
        let schema = Schema([ContentItem.self, ProjectItem.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        return try! ModelContainer(for: schema, configurations: [configuration])
    }()

    init() {
        // SwiftUI's `.scrollContentBackground(.hidden)` alone leaves a residual
        // opaque table background on some OS versions; forcing it clear here lets
        // our own Palette-driven background paint through everywhere.
        UITableView.appearance().backgroundColor = .clear
        UICollectionView.appearance().backgroundColor = .clear
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(themeStore.mode.preferredColorScheme)
                .environment(themeStore)
        }
        .modelContainer(container)
    }
}
