import Foundation
import SwiftData

@Model
final class Food {
    var name: String = ""
    var brand: String = ""
    var sortOrder: Int = 0

    init(name: String = "", brand: String = "") {
        self.name = name
        self.brand = brand
    }
}
