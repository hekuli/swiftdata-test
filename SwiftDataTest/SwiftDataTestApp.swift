import SwiftUI
import SwiftData

@main
struct SwiftDataTestApp: App {
    var modelContainer: ModelContainer

    init() {
        let schema = Schema([Person.self])
        let modelConfig = ModelConfiguration("ThrowawayApp", schema: schema)
        do {
            modelContainer = try ModelContainer(for: schema, configurations: modelConfig)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            PeopleListView()
        }
        .modelContainer(modelContainer)
        .environment(ModelFactory(modelContainer.mainContext))
    }

}
