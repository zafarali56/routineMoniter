import SwiftUI

struct RoutineListView: View {
	@StateObject private var viewModel = RoutineViewModel()

	var body: some View {
		NavigationView {
			List {
				ForEach(viewModel.routines, id: \.id) { routine in
					RoutineView(routine: routine)
						.onTapGesture {
							viewModel.selectedRoutine = routine
							viewModel.isEditing = true
						}
						.padding(.vertical, 4)
				}
				.onDelete { indexSet in
					viewModel.removeRoutine(at: indexSet)
				}
			}
			.navigationTitle("My Routines")
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					Button {
						viewModel.addRoutine() // Open EditRoutineView
					} label: {
						Image(systemName: "plus")
					}
				}
			}
			.sheet(item: $viewModel.selectedRoutine) { routine in
				EditRoutineView(routine: routine) { title, description, time in
					// Save the routine only when the user presses Save
					viewModel.updateRoutine(routine, title: title, description: description, time: time)
				}
			}

		}
	}
}

#Preview {
	RoutineListView()
}
import SwiftUI

struct EditRoutineView: View {
	var routine: RoutineEntity
	var onSave: (String, String, Date) -> Void

	@Environment(\.dismiss) private var dismiss
	@State private var title: String = ""
	@State private var description: String = ""
	@State private var time: Date = Date()

	var body: some View {
		NavigationView {
			Form {
				TextField("Title", text: $title)
				TextField("Description", text: $description)
				DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)
			}
			.navigationTitle("Edit Routine")
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					Button("Save") {
						onSave(title, description, time) // Save the data
						dismiss() // Dismiss the view after saving
					}
				}
				ToolbarItem(placement: .navigationBarLeading) {
					Button("Cancel") {
						dismiss() // Simply dismiss without saving
					}
				}
			}
		}
		.onAppear {
			// Populate the fields with existing routine data
			title = routine.title ?? ""
			description = routine.routineDescription ?? ""
			time = routine.time ?? Date()
		}
	}
}
