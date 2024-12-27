import CoreData

class CoreDataManager {
	static let shared = CoreDataManager()

	let persistentContainer: NSPersistentContainer
	init() {
		// Initialize the persistent container with the correct name
		persistentContainer = NSPersistentContainer(name: "Routine") // Matches the .xcdatamodeld file name
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
