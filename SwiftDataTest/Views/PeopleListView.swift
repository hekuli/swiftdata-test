import SwiftUI
import SwiftData

struct PeopleListView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var factory: ModelFactory
    @Query(sort: \Person.name) private var people: [Person]
    @State var path = NavigationPath()

    var body: some View {
        VStack {
            NavigationStack(path: $path) {
                List {
                    Section() {
                        Button("Create Sample Data") {
                            _ = factory.createSamplData()
                        }
                        Button("Delete ALL Data", role: .destructive) {
                            do {
                                try modelContext.delete(model: Person.self)
                            } catch {
                                print("Failed to clear all data.")
                            }
                        }
                    }
                    Section("People") {
                        ForEach(people) { person in
                            NavigationLink(value: person) {
                                Text(person.name)
                            }
                        }
                        .onDelete(perform: { indexSet in
                            for index in indexSet {
                                modelContext.delete(people[index])
                            }
                        })
                    }
                }
                .navigationDestination(for: Person.self) { person in
                    PersonView(person: person, path: $path)
                }
                .navigationDestination(for: Pet.self) { pet in
                    PetView(pet: pet, path: $path)
                }
                .navigationDestination(for: Food.self) { food in
                    FoodView(food: food, path: $path)
                }
                .navigationTitle("People List")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem {
                        Button(action: { path.append(factory.newRandomPerson()) }) {
                            Label("Add Random Person", systemImage: "plus.square.dashed")
                        }
                    }
                    ToolbarItem {
                        Button(action: { path.append(factory.newPerson()) }) {
                            Label("Add Empty Person", systemImage: "plus")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    let (factory, container) = ModelFactory.createPreviewFactory()

    _ = factory.createSamplData()

    return NavigationStack {
        PeopleListView()
    }
    .modelContainer(container)
    .environment(factory)
}
