import Foundation
import Combine
import CoreData
import FirebaseFirestore

class RoutineViewModel: ObservableObject {
	@Published var routines: [RoutineEntity] = []
	@Published var selectedRoutine: RoutineEntity?
	@Published var isEditing: Bool = false
	private var cancellables: Set<AnyCancellable> = []


	private let manager = CoreDataManager.shared
	private var context: NSManagedObjectContext {
		return manager.context
	}
	private let db = Firestore.firestore()
	private let collectionName = "routines"

	init() {
		fetchRoutines()
		fetchRoutinesFromFirestore()
		
		// Observe network connectivity
		NetworkMonitor.shared.$isConnected
			.sink { [weak self] isConnected in
				if isConnected {
					self?.syncUnsyncedRoutines()
				}
			}
			.store(in: &cancellables)
	}


	// Fetch routines from Core Data
	func fetchRoutines() {
		let fetchRequest: NSFetchRequest<RoutineEntity> = RoutineEntity.fetchRequest() as! NSFetchRequest<RoutineEntity>
		do {
			let routines = try context.fetch(fetchRequest)
			print("Fetched routines: \(routines.map { $0.id ?? "No ID" })")
			self.routines = routines
		} catch {
			print("Failed to fetch routines: \(error)")
		}
	}

	// Fetch routines from Firestore and save them to Core Data if they don't already exist
	func fetchRoutinesFromFirestore() {
		db.collection(collectionName).getDocuments { [weak self] snapshot, error in
			guard let self = self else { return }
			guard let documents = snapshot?.documents else {
				print("Error fetching documents: \(String(describing: error))")
				return
			}
			for document in documents {
				self.saveRoutineFromFirestore(data: document.data())
			}
		}
	}

	// Save routine data from Firestore to Core Data
	private func saveRoutineFromFirestore(data: [String: Any]) {
		guard let id = data["id"] as? String,
			  let title = data["title"] as? String,
			  let description = data["description"] as? String,
			  let timestamp = data["time"] as? Timestamp else {
			print("Invalid Firestore data format")
			return
		}

		// Explicitly cast fetch request to RoutineEntity type
		let fetchRequest: NSFetchRequest<RoutineEntity> = RoutineEntity.fetchRequest() as! NSFetchRequest<RoutineEntity>
		fetchRequest.predicate = NSPredicate(format: "id == %@", id)

		do {
			let existingRoutines = try context.fetch(fetchRequest)
			if existingRoutines.isEmpty {
				// Only create a new routine if it doesn't exist
				let routine = RoutineEntity(context: context)
				routine.id = id
				routine.title = title
				routine.routineDescription = description
				routine.time = timestamp.dateValue()

				manager.save()
			}
		} catch {
			print("Failed to fetch existing routine: \(error)")
		}
	}

	// Save routine to Firestore
	func saveRoutineToFirestore(routine: RoutineEntity) {
		guard let id = routine.id,
			  let title = routine.title,
			  let description = routine.routineDescription,
			  let time = routine.time else {
			print("Routine data is incomplete")
			return
		}

		let data: [String: Any] = [
			"id": id,
			"title": title,
			"description": description,
			"time": Timestamp(date: time)
		]

		db.collection(collectionName).document(id).setData(data) { error in
			if let error = error {
				print("Error saving to Firestore: \(error)")
				routine.needsSync = true // Mark for sync
				self.manager.save()
			} else {
				print("Successfully saved routine to Firestore")
				routine.needsSync = false // Clear sync flag
				self.manager.save()
			}
		}
	}
	func syncUnsyncedRoutines() {
		let fetchRequest: NSFetchRequest<RoutineEntity> = RoutineEntity.fetchRequest() as! NSFetchRequest<RoutineEntity>
		fetchRequest.predicate = NSPredicate(format: "needsSync == %@", NSNumber(value: true))

		do {
			let unsyncedRoutines = try context.fetch(fetchRequest)
			for routine in unsyncedRoutines {
				saveRoutineToFirestore(routine: routine)
			}
		} catch {
			print("Failed to fetch unsynced routines: \(error)")
		}
	}

	// Add a new routine and open it in EditRoutineView
	func addRoutine() {
		let newRoutine = RoutineEntity(context: context)
		newRoutine.id = UUID().uuidString
		newRoutine.title = "" // Placeholder for user input
		newRoutine.routineDescription = "" // Placeholder for user input
		newRoutine.time = Date() // Default value

		// Set for editing only; do not save
		selectedRoutine = newRoutine
		isEditing = true
	}

	// Remove routine from Core Data and Firestore
	func removeRoutine(at offsets: IndexSet) {
		offsets.forEach { index in
			let routine = routines[index]
			deleteRoutineFromFirestore(routine: routine)
			context.delete(routine)
		}
		manager.save()
		fetchRoutines()
	}

	// Delete routine from Firestore
	func deleteRoutineFromFirestore(routine: RoutineEntity) {
		guard let id = routine.id else { return }
		db.collection(collectionName).document(id).delete { error in
			if let error = error {
				print("Error deleting from Firestore: \(error)")
			}
		}
	}

	// Update an existing routine
	func updateRoutine(_ routine: RoutineEntity, title: String, description: String, time: Date) {
		routine.title = title
		routine.routineDescription = description
		routine.time = time
		routine.needsSync = true // Mark as needing sync

		CoreDataManager.shared.save()
	}


}
