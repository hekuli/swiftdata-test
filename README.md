# SwiftDataTest

A simple example project (based on a real project) demonstrating how to avoid the issues I encountered while working SwiftData, XCode 15, and iOS 17.2.

For the purposes of this simplified demo app, the following is assumed b/c it's what is required in my real more complex app:
- Models are nested with one-to-many relationships.
- Models only make sense in this nested structure.
- It makes no sense for nested model instances to exist on their own without a parent (hence the cascading deletes).
  i.e. Pets do not exist without their person, and PetFoods do not exist without a Pet.

Try using the app. Especially note the sort ordering of the list items and how the long-press drag-to-reorder and swipe-to-delete works.

Warnings are sprikled throughout the code to highlight the issues below.

## Open Questions/Issues

Even after watching all the WWDC2023 SwiftData videos, reading the docs, and going through the HackingWithSwift.com series, spending countless hours on Apple Developer forums and StackOverflow...
I'm still struggling to understand the following:

### 1 : It seems it is not possible to create/modify array properties on models if they contain other models without first doing a `context.insert(parent)`. Is this by design? What is the rational? What are the rules for safe mutations?

This prevents model classes from doing any kind of mutation (and therefore meaning manipulation) of their children b/c there is no context available within the model to perform the required insert/saves with, and some changes without calling insert()/save() first result in crashes.
I see nothing in the docs stating models cannot mutate their model members.
To get around these restrictions I use a Factory pattern and do all the major manipulation logic there, and in the views do not do anything with models other than very simple property setting or single item deletion.
Is this the recommended design pattern? Or?
See code in: `Models/ModelFactory.swift`

### 2: Is it possible (using ANY architecture/schema/approach) to display child models in sorted order that allows reordering? 

When fetching parent objects, any children models embedded in an array property always come back in random order.
Some have suggested simply sorting the items with a calculated property. This is fine for display only values, but does not work in practice if you want to allow the user to reorder items and persist that new order to the database.

So additional tedious boilerplate code is required to get everything working properly.
- Access to the array must be abstracted with a computed property that sorts the items
- Custom `sortOrder` properties must be added to the models
- Custom append() methods must be used to set the sort order of new items
- Custom delete() and move() methods must be used which update the sortOrder properties upon mutation.

Examples of this exist in `Models/Person.swift`

### 3: Why do previews always crash with nested data models and generalized model config?

I discovered [this handy trick](https://www.youtube.com/watch?v=tZq4mvqH9Fg&t=646s) to DRY up the code for creating Previews with SwiftData Models.
In simple cases with just one model, it works really well. But when you have multiple nested models, for some unknown reason the general nature of the function somehow causes the preview to repeatedly crash.
This happens regardless of the order in which items are inserted.
It seems any usage of `any PersistentModel.Type` is not able to infer nested sub-types when defining a `ModelContainer` or something.

As it turns out I prefer the Factory approach I'm using better anyway.

## Other Approaches I Tried

### Copying the sorted things into a new separate array on the view, then writing them back after any change.

This was error prone as the code to manage things was strewn out across many different views. It was easy to forget to do things in the correct order.

### Running a different @Query on each sub view

For example the PetsView would contain something like:
`@Query(sort: \Food.sortOrder) private var foods: [foods]`

Aside from being inefficient and adding more complexity, this didn't work because:
1. It seems not possible to filter the query with something like `WHERE pet.personID = 'xyz'`
1. The fetched array is readonly and can't be mutated making manipulation more tedious

### Calling context.insert()/delete() methods from within the parent model

This generally seems like a bad idea, but I tried it just to see.
It turns out the modelContext property on the models is always empty anyway.
