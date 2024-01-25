import Foundation
import SwiftData

@Model
final class Pet {
    var name: String = ""
    var animalType: String = ""
    var sortOrder: Int = 0

    @Relationship(deleteRule: .cascade) private var _favoritFoods: [Food] = []

    var favoriteFoods: [Food] {
        return _favoritFoods.sorted(using: KeyPathComparator(\Food.sortOrder))
    }

    init(name: String = "", animalType: String = "", favoritFoods: [Food] = []) {
        self.name = name
        self.animalType = animalType
        self.setFoods(orderedFoods: favoritFoods)
    }

    func appendFood(_ food: Food) {
        var tempArray = favoriteFoods
        food.sortOrder = tempArray.count
        tempArray.append(food)
        _favoritFoods = tempArray
    }

    func deleteFood(fromOffsets: IndexSet) {
        var tempArray = favoriteFoods
        tempArray.remove(atOffsets: fromOffsets)
        setFoods(orderedFoods: tempArray)
    }

    func moveFood(fromOffsets: IndexSet, toOffset: Int) {
        var tempArray = favoriteFoods
        tempArray.move(fromOffsets: fromOffsets, toOffset: toOffset)
        setFoods(orderedFoods: tempArray)
    }

    func setFoods(orderedFoods: [Food]) {
        for (index, food) in orderedFoods.enumerated() {
            food.sortOrder = index
        }
        _favoritFoods = orderedFoods
    }

}
