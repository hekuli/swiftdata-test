import SwiftUI
import SwiftData

struct FoodView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var factory: ModelFactory
    @Bindable var food: Food
    @Binding var path: NavigationPath

    var body: some View {
        List {
            TextField("Name", text: $food.name)
            TextField("Brand", text: $food.brand)
        }
        .navigationTitle("Food Detail")
    }
}

#Preview {
    let (factory, container) = ModelFactory.createPreviewFactory()

    let people = factory.createSamplData()
    let food = people.first?.pets.first!.favoriteFoods.first!

    return NavigationStack {
        FoodView(food: food!, path: Binding.constant(NavigationPath()))
    }
    .modelContainer(container)
    .environment(factory)
}
