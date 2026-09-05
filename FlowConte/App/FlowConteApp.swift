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

    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(themeStore.mode.preferredColorScheme)
                .environment(themeStore)
        }
        .modelContainer(container)
    }
}
