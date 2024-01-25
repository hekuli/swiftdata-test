import SwiftUI
import SwiftData

struct PetView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var factory: ModelFactory
    @Bindable var pet: Pet
    @Binding var path: NavigationPath

    var body: some View {
        List {
            TextField("Name", text: $pet.name)
            TextField("Type", text: $pet.animalType)
            #warning("See Q2: By default these items are always in random order and impossible to retrieve in sorted order from the database")
            // NOTE: pet._favoritFoods raw model array will always be in random order and ordering changes cannot be saved)
            // therefore the computed property that sorts the array must be used.
            Section("Favorite Foods") {
                ForEach(pet.favoriteFoods) { food in
                    NavigationLink(value: food) {
                        Text("\(food.name) (\(food.sortOrder))")
                    }
                }
                .onMove(perform: pet.moveFood)
                .onDelete(perform: pet.deleteFood)
            }
        }
        .navigationTitle("Pet Detail")
        .toolbar {
            ToolbarItem {
                Button(action: { let _ = factory.newRandomFood(pet: pet) }) {
                    Label("Add Random Food", systemImage: "plus.square.dashed")
                }
            }
            ToolbarItem {
                Button(action: { let _ = factory.newFood(for: pet) }) {
                    Label("Add Empty Food", systemImage: "plus")
                }
            }
        }

    }

}

#Preview {
    let (factory, container) = ModelFactory.createPreviewFactory()

    let people = factory.createSamplData()
    let pet = people.first?.pets.first!

    return NavigationStack {
        PetView(pet: pet!, path: Binding.constant(NavigationPath()))
    }
    .modelContainer(container)
    .environment(factory)
}
