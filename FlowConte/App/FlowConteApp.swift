import SwiftUI
import SwiftData

@main
struct FlowConteApp: App {
    @State private var themeStore = ThemeStore()

    var container: ModelContainer = {
        let schema = Schema([ContentItem.self, ProjectItem.self])
        // UI tests opt into an isolated in-memory store so each test run starts
        // from a clean slate without touching the real on-disk user data.
        let isUITesting = ProcessInfo.processInfo.arguments.contains("-UITest_ResetStore")
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: isUITesting)
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
                .paletteAware()
        }
        .modelContainer(container)
    }
}
