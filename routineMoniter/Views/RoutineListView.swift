import SwiftUI

import SwiftUI

struct RoutineListView: View {
	@StateObject private var viewModel = RoutineViewModel()

	var body: some View {
		NavigationView {
			List {
				ForEach(viewModel.routines, id: \.self) { routine in
					RoutineView(routine: routine, onDelete: {
						$viewModel.deleteRoutine(routine)
					})
					.onTapGesture {
						viewModel.selectedRoutine = routine
						viewModel.isEditing = true
					}
					.padding(.vertical, 4)
				}
				.onDelete(perform: viewModel.removeRoutine)
			}
			.navigationTitle("My Routines")
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					Button(action: viewModel.addRoutine) {
						Image(systemName: "plus")
					}
				}
			}
			.sheet(item: $viewModel.selectedRoutine) { routine in
				EditRoutineView(routine: routine) { title, description, time in
					viewModel.updateRoutine(routine, title: title, description: description, time: time)
				}
			}
		}
	}
}


#Preview {
	RoutineListView()
}


struct EditRoutineView: View {
	var routine: RoutineEntity
	var onSave: (String, String, Date) -> Void

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
						onSave(title, description, time)
					}
				}
				ToolbarItem(placement: .navigationBarLeading) {
					Button("Cancel") {
						// Dismiss
					}
				}
			}
		}
		.onAppear {
			title = routine.title ?? ""
			description = routine.routineDescription ?? ""
			time = routine.time ?? Date()
		}
	}
}
