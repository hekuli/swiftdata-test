import Foundation
import SwiftData

@Model
final class Person {
    var name: String = ""

    #warning("See Q2: Make the actual persisted array private to avoid making mistakes with setting sort orders")
    @Relationship(deleteRule: .cascade) private var _pets: [Pet] = []

    #warning("See Q2: All outside access to the array is via this computed property that ensures sorted values are returned")
    var pets: [Pet] {
        return _pets.sorted(using: KeyPathComparator(\Pet.sortOrder))
    }

    init(name: String = "", pets: [Pet] = []) {
        self.name = name
        // Ensure pets get the right ordering
        self.setPets(orderedPets: pets)
    }

    #warning("See Q2: Use a custom append method here to ensure ordering is set properly")
    func appendPet(_ pet: Pet) {
        var tempArray = pets
        pet.sortOrder = tempArray.count
        tempArray.append(pet)
        _pets = tempArray
    }

    // Deletes a specific pet
    func deletePet(pet: Pet) {
        _pets.removeAll { $0 == pet }
    }

    // Assumes the indexes are from the sorted version of the list
    #warning("See Q2: Since we have to track the ordering manually with our own property, we have to update the ordering after deletion too")
    func deletePet(fromOffsets: IndexSet) {
        var tempArray = pets
        tempArray.remove(atOffsets: fromOffsets)
        setPets(orderedPets: tempArray)
    }

    #warning("See Q2: This is the only way to get re-ordering to work")
    func movePet(fromOffsets: IndexSet, toOffset: Int) {
        var tempArray = pets
        tempArray.move(fromOffsets: fromOffsets, toOffset: toOffset)
        setPets(orderedPets: tempArray)
    }

    // Assigns the proper sortOrder property to each pet.
    // Then assigns the Person.pets array to the provided array.
    // NOTE: provided array MUST already be in sorted order.
    #warning("See Q2: After any mutation to the pets array need to remember to call this to update the orderings")
    func setPets(orderedPets: [Pet]) {
        for (index, pet) in orderedPets.enumerated() {
            pet.sortOrder = index
        }
        _pets = orderedPets
    }

}
