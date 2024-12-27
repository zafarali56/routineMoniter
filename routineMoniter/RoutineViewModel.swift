import Foundation
import Combine
import CoreData
import FirebaseFirestore

class RoutineViewModel: ObservableObject {
	@Published var routines: [RoutineEntity] = []
	@Published var selectedRoutine: RoutineEntity?
	@Published var isEditing: Bool = false

	private let manager = CoreDataManager.shared
	private var context: NSManagedObjectContext {
		return manager.context
	}
	private let db = Firestore.firestore()
	private let collectionName = "routines"

	init() {
		fetchRoutines()
		fetchRoutinesFromFirestore()
	}

	// MARK: - Core Data Fetch
	func fetchRoutines() {
		let fetchRequest: NSFetchRequest<RoutineEntity> = RoutineEntity.fetchRequest() as! NSFetchRequest<RoutineEntity>
		do {
			self.routines = try context.fetch(fetchRequest)
		} catch {
			print("Failed to fetch routines: \(error)")
		}
	}

	// MARK: - Firestore Fetch
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

	private func saveRoutineFromFirestore(data: [String: Any]) {
		guard let id = data["id"] as? String,
			  let title = data["title"] as? String,
			  let description = data["description"] as? String,
			  let timestamp = data["time"] as? Timestamp else {
			print("Invalid Firestore data format")
			return
		}

		let routine = RoutineEntity(context: context)
		routine.id = id
		routine.title = title
		routine.routineDescription = description
		routine.time = timestamp.dateValue()

		manager.save()
		fetchRoutines() // Update local cache after fetching Firestore data
	}

	// MARK: - Add Routine
	func addRoutine() {
		let newRoutine = RoutineEntity(context: context)
		newRoutine.id = UUID().uuidString
		newRoutine.title = "New Routine"
		newRoutine.routineDescription = "Routine description"
		newRoutine.time = Date().addingTimeInterval(3600)

		saveRoutineToFirestore(routine: newRoutine)
		manager.save()
		fetchRoutines()
	}

	// MARK: - Remove Routine
	func removeRoutine(at offsets: IndexSet) {
		offsets.forEach { index in
			let routine = routines[index]
			deleteRoutineFromFirestore(routine: routine)
			context.delete(routine)
		}
		manager.save()
		fetchRoutines()
	}

	func deleteRoutine(_ routine: RoutineEntity) {
		context.delete(routine)
		deleteRoutineFromFirestore(routine: routine)
		manager.save()
		fetchRoutines()
	}

	// MARK: - Update Routine
	func updateRoutine(_ routine: RoutineEntity, title: String, description: String, time: Date) {
		routine.title = title
		routine.routineDescription = description
		routine.time = time

		saveRoutineToFirestore(routine: routine)
		manager.save()
		fetchRoutines()
	}

	// MARK: - Firestore Sync
	// MARK: - Firestore Sync
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
			}
		}
	}

	func deleteRoutineFromFirestore(routine: RoutineEntity) {
		guard let id = routine.id else { return }
		db.collection(collectionName).document(id).delete { error in
			if let error = error {
				print("Error deleting from Firestore: \(error)")
			}
		}
	}
}
