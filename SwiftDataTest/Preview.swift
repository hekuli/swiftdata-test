import Foundation
import SwiftData

#warning("See Q3: This approach consistently crashes the preview for me (See: PersonView.swift). I stopped using it.")
// Helper to create inmemory preview data for any type. Only works in some cases.
struct Preview {
    let container: ModelContainer

    init(_ models: any PersistentModel.Type...) {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let schema = Schema(models)
        do {
            try container = ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Couldn't create preview container")
        }
    }

    func addExamples(_ examples: [any PersistentModel]) {
        Task { @MainActor in
            examples.forEach { example in
                container.mainContext.insert(example)
            }
        }
    }

}
