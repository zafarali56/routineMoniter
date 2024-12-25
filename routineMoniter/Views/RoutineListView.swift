import SwiftUICore
import SwiftUI


struct RoutineListView: View {
	@State private var routines: [Routine] = [
		Routine(id: UUID().uuidString, title: "Morning Run", description: "Go for a 5km run", time: Date()),
		Routine(id: UUID().uuidString, title: "Team Meeting", description: "Daily stand-up with the team", time: Date().addingTimeInterval(3600)),
		Routine(id: UUID().uuidString, title: "Workout", description: "Complete upper body workout", time: Date().addingTimeInterval(7200))
	]
	@State private var selectedRoutine: Routine? = nil
	@State private var isEditing: Bool = false

	var body: some View {
		NavigationView {
			List {
				ForEach(routines) { routine in
					RoutineView(routine: routine)
						.onTapGesture {
							selectedRoutine = routine
							isEditing = true
						}
						.padding(.vertical, 4)
				}
				.onDelete(perform: removeRoutine)
			}
			.navigationTitle("My Routines")
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					Button(action: addRoutine) {
						Image(systemName: "plus")
					}
				}
			}
			.sheet(item: $selectedRoutine) { routine in
				EditRoutineView(routine: $routines[routines.firstIndex(where: { $0.id == routine.id })!])
			}
		}
	}

	func addRoutine() {
		let newRoutine = Routine(id: UUID().uuidString, title: "New Routine", description: "Routine description", time: Date().addingTimeInterval(3600))
		routines.append(newRoutine)
	}

	func removeRoutine(at offsets: IndexSet) {
		routines.remove(atOffsets: offsets)
	}
}

#Preview {
	RoutineListView()
}


struct EditRoutineView: View {
	@Binding var routine: Routine

	var body: some View {
		NavigationView {
			Form {
				TextField("Title", text: $routine.title)
				TextField("Description", text: $routine.description)
				DatePicker("Time", selection: $routine.time, displayedComponents: .hourAndMinute)
			}
			.navigationTitle("Edit Routine")
			.toolbar {
				ToolbarItem(placement: .navigationBarLeading) {
					Button("Cancel") {
						// Dismiss sheet
						UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true)
					}
				}
			}
		}
	}
}
