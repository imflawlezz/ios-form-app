import CoreData
import Foundation

@MainActor
final class CoreDataStack {
    let container: NSPersistentContainer

    init(modelName: String = "Model") {
        container = NSPersistentContainer(name: modelName)
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Unresolved CoreData error: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}

