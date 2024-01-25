import SwiftUI
import SwiftData

struct PersonView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var factory: ModelFactory
    @Bindable var person: Person
    @Binding var path: NavigationPath

    var body: some View {
        VStack {
            List {
                TextField("Name", text: $person.name)
                Section("Pets") {
                    ForEach(person.pets) { pet in
                        NavigationLink(value: pet) {
                            Text("\(pet.name) (\(pet.sortOrder))")
                        }
                        .swipeActions(allowsFullSwipe: false) {
                            // NOTE: Using swipeActions here to illustrate how to delete a specific pet object
                            //  (as opposed to useing an IndexSet with the normal .onDelete() approach)
                            Button(role: .destructive, action: { person.deletePet(pet: pet) }) {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                    .onMove(perform: person.movePet)
                }
            }
            .navigationTitle("Person Detail")
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        let pet = factory.newRandomPet(person: person)
                        path.append(pet)
                    }) {
                        Label("Add Random Pet", systemImage: "plus.square.dashed")
                    }
                }
                ToolbarItem {
                    Button(action: {
                        let pet = factory.newPet(for: person)
                        path.append(pet)
                    }) {
                        Label("Add Empty Pet", systemImage: "plus")
                    }
                }
            }
        }
    }


}

// THIS WORKS!
#Preview {
    let (factory, container) = ModelFactory.createPreviewFactory()

    let person = factory.newPerson()
    person.name = "Jon Doe"
    let pet1 = factory.newPet(for: person)
    pet1.name = "Fido-1"
    let pet2 = factory.newPet(for: person)
    pet2.name = "Pluto-1"

    return NavigationStack() {
        PersonView(person: person, path: Binding.constant(NavigationPath()))
    }
    .modelContainer(container)
    .environment(factory)
}

#warning("See Q3: Using the Preview class approach consistently crashes the preview for me, sometimes very hard with a MacOS alert that the process has died")
// This does NOT work
//#Preview {
//    // Attempt to create custom nested preview data leveraging the general Preview class.
//    // This works ocassionally but usually causes the preview canvas to crash.
//    let preview = Preview(Person.self)
//    let person = Person()
//    person.name = "Jon Doe"
//    let pet1 = Pet()
//    pet1.name = "Fido-1"
//    let pet2 = Pet()
//    pet2.name = "Pluto-1"
//    let pets = [pet1, pet2]
//
//    // Regardless of the ordering here, the preview still crashes
//    preview.addExamples(pets)
//    preview.addExamples([person])
//    person.setPets(orderedPets: [pet1, pet2])
//
//    let factory = ModelFactory(preview.container.mainContext)
//    return NavigationStack {
//        PersonView(person: person, path: Binding.constant(NavigationPath()))
//    }
//    .modelContainer(preview.container)
//    .environment(factory)
//}
