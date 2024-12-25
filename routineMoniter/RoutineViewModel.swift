import Foundation
import Combine

class RoutineViewModel: ObservableObject {
	@Published var routines: [Routine] = []
	@Published var selectedRoutine: Routine?
	@Published var isEditing: Bool = false
	
	private var cancellables = Set<AnyCancellable>()

	init() {
		// Load initial routines or fetch from a database/network if needed
		loadInitialRoutines()
	}

	func loadInitialRoutines() {
		routines = [
			Routine(id: UUID().uuidString, title: "Morning Run", description: "Go for a 5km run", time: Date()),
			Routine(id: UUID().uuidString, title: "Team Meeting", description: "Daily stand-up with the team", time: Date().addingTimeInterval(3600)),
			Routine(id: UUID().uuidString, title: "Workout", description: "Complete upper body workout", time: Date().addingTimeInterval(7200))
		]
	}

	func addRoutine() {
		let newRoutine = Routine(id: UUID().uuidString, title: "New Routine", description: "Routine description", time: Date().addingTimeInterval(3600))
		routines.append(newRoutine)
	}

	func removeRoutine(at offsets: IndexSet) {
		routines.remove(atOffsets: offsets)
	}

	func deleteRoutine(_ routine: Routine) {
		if let index = routines.firstIndex(where: { $0.id == routine.id }) {
			routines.remove(at: index)
		}
	}

	func updateRoutine(_ updatedRoutine: Routine) {
		if let index = routines.firstIndex(where: { $0.id == updatedRoutine.id }) {
			routines[index] = updatedRoutine
		}
	}
}
