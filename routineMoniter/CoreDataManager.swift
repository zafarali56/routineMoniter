import CoreData

class CoreDataManager {
	static let shared = CoreDataManager()

	let persistentContainer: NSPersistentContainer
	init() {
		persistentContainer = NSPersistentContainer(name: "Routine")
		persistentContainer.loadPersistentStores { description, error in
			if let error = error {
				fatalError("Unable to initialize Core Data: \(error)")
			}
		}
	}
	var context: NSManagedObjectContext {
		return persistentContainer.viewContext
	}
	func save() {
		if context.hasChanges {
			do {
				try context.save()
			} catch {
				print("Failed to save Core Data context: \(error)")
			}
		}
	}
}
