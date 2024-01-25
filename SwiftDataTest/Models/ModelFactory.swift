import Foundation
import SwiftData

#warning("See Q1: This is the factory pattern used for model manipulation.")
@Observable
class ModelFactory: ObservableObject {
    var context: ModelContext

    init(_ modelContext: ModelContext) {
        self.context = modelContext
    }

    func newPerson() -> Person {
        let newPerson = Person()
        context.insert(newPerson)
        return newPerson
    }

    func newPet(for person: Person) -> Pet {
        let newPet = Pet()
        context.insert(newPet)
        person.appendPet(newPet)
        return newPet
    }

    func newFood(for pet: Pet) -> Food {
        let newFood = Food()
        context.insert(newFood)
        pet.appendFood(newFood)
        return newFood
    }
}

// --------------------------------------------------------------------------------
// Everything below here is just for creating sample and preview data
// --------------------------------------------------------------------------------
extension ModelFactory {
    static let firstNames = ["Jon", "Matilda", "Henry", "Nancy"]
    static let lastNames = ["Doe", "Piper", "Bockman", "Muller"]
    static let titles = ["Mr.", "Miss", "Mrs.", "Dr.", "Ms.", "Princess", "Prince", "Sir", "Duke"]
    static let petNames = ["Twinkles", "Fido", "Bigsby", "Santa's Little Helper", "Fluffers"]
    static let animalTypes = ["Cat", "Dog", "Hedgehog", "Bunny", "Goat", "Hamster"]
    static let foods = ["Beef", "Chicken", "Kibble", "Scoobie Snacks", "Ox Tail", "Grass", "Carrots"]
    static let foodBrands = ["Nom-Noms.com", "petfood.com", "Treats R' Us", "Yum-Yums"]

    // Convenience function for creating in-memory container/factory for previews
    @MainActor
    static func createPreviewFactory() -> (ModelFactory, ModelContainer) {
        let modelConfig = ModelConfiguration(isStoredInMemoryOnly: true)
        let modelContainer = try! ModelContainer(for: Person.self, configurations: modelConfig)
        return (ModelFactory(modelContainer.mainContext), modelContainer)
    }

    func newRandomPerson() -> Person {
        let newPerson = genPerson(suffix: genUniqueSuffix())
        context.insert(newPerson)
        return newPerson
    }

    func newRandomPet(person: Person) -> Pet {
        let newPet = genPet(suffix: genUniqueSuffix())
        context.insert(newPet)
        person.appendPet(newPet)
        return newPet
    }

    func newRandomFood(pet: Pet) -> Food {
        let newFood = genFood(suffix: genUniqueSuffix())
        context.insert(newFood)
        pet.appendFood(newFood)
        return newFood
    }

    private func genUniqueSuffix() -> String {
        return String(UUID().uuidString.prefix(4))
    }

    private func genPerson(suffix: String) -> Person {
        return Person(name: "\(ModelFactory.firstNames.randomElement()!) \(ModelFactory.lastNames.randomElement()!)")
    }

    private func genPet(suffix: String) -> Pet {
        let name = "\(ModelFactory.titles.randomElement()!) \(ModelFactory.petNames.randomElement()!)"
        return Pet(name: "\(name)-\(suffix)", animalType: ModelFactory.animalTypes.randomElement()!)
    }

    private func genFood(suffix: String) -> Food {
        return Food(name: "\(ModelFactory.foods.randomElement()!)-\(suffix)",
                       brand: ModelFactory.foodBrands.randomElement()!)
    }

    // NOTE: The ordering of the insert() calls is very intentional. Moving them around causes crashes.
    func createSamplData() -> [Person] {
        var people: [Person] = []
        for i in 0...5 {
            var newPets: [Pet] = []
            for j in 0...Int.random(in: 3...8) {
                var newPetFoods: [Food] = []
                for k in 0...Int.random(in: 3...8) {
                    let newFood = genFood(suffix: String(k))
                    newPetFoods.append(newFood)
                }
                let newPet = genPet(suffix: String(j))
                newPet.setFoods(orderedFoods: newPetFoods)
                newPets.append(newPet)
            }
            let newPerson = genPerson(suffix: String(i))
            newPerson.setPets(orderedPets: newPets)
            context.insert(newPerson)
            people.append(newPerson)
        }
        return people
    }
}
