import CoreData
import CloudKit

class DataController: ObservableObject {
    let container: NSPersistentCloudKitContainer

    init() {
        container = NSPersistentCloudKitContainer(name: "CoreDataModels")

        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("Failed to retrieve persistent store description")
        }

        description.setOption(true as NSNumber,
                              forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber,
                              forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true

        Task {
            await seedInitialData()
        }
    }

    func save() {
        let context = container.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error)")
            }
        }
    }

    func seedInitialData() async {
        let context = container.viewContext

        let request: NSFetchRequest<State> = State.fetchRequest()
        let count = try? context.count(for: request)

        guard count == 0 else { return }

        let initialStates = [
            ("California", "CA"),
            ("Texas", "TX"),
            ("New York", "NY"),
            ("Florida", "FL"),
            ("Illinois", "IL")
        ]

        for (name, code) in initialStates {
            let state = State(context: context)
            state.name = name
            state.code = code
            state.lastUpdated = Date()
        }

        let categories = [
            ("Tenant Rights", "house.fill"),
            ("Traffic Laws", "car.fill"),
            ("Employment", "briefcase.fill"),
            ("Consumer Rights", "cart.fill"),
            ("Tax Laws", "dollarsign.circle.fill")
        ]

        for (index, (name, icon)) in categories.enumerated() {
            let category = LawCategory(context: context)
            category.name = name
            category.icon = icon
            category.order = Int16(index)
        }

        save()
    }

    func fetchState(byCode code: String) -> State? {
        let request: NSFetchRequest<State> = State.fetchRequest()
        request.predicate = NSPredicate(format: "code == %@", code)
        request.fetchLimit = 1

        do {
            let states = try container.viewContext.fetch(request)
            return states.first
        } catch {
            print("Failed to fetch state: \(error)")
            return nil
        }
    }

    func fetchLaws(for state: String, category: String? = nil) -> [Law] {
        let request: NSFetchRequest<Law> = Law.fetchRequest()

        var predicates = [NSPredicate(format: "state.code == %@", state)]

        if let category = category {
            predicates.append(NSPredicate(format: "category.name == %@", category))
        }

        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Law.title, ascending: true)]

        do {
            return try container.viewContext.fetch(request)
        } catch {
            print("Failed to fetch laws: \(error)")
            return []
        }
    }

    func fetchCategories() -> [LawCategory] {
        let request: NSFetchRequest<LawCategory> = LawCategory.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \LawCategory.order, ascending: true)]

        do {
            return try container.viewContext.fetch(request)
        } catch {
            print("Failed to fetch categories: \(error)")
            return []
        }
    }

    func addBookmark(for law: Law, notes: String? = nil) {
        let bookmark = Bookmark(context: container.viewContext)
        bookmark.law = law
        bookmark.notes = notes
        bookmark.dateAdded = Date()
        save()
    }

    func removeBookmark(_ bookmark: Bookmark) {
        container.viewContext.delete(bookmark)
        save()
    }

    func saveDocument(title: String, content: Data, type: String, templateName: String, state: String) {
        let document = Document(context: container.viewContext)
        document.title = title
        document.content = content
        document.type = type
        document.templateName = templateName
        document.state = state
        document.generatedDate = Date()
        save()
    }
}