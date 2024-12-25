import SwiftUICore
import SwiftUI

struct RoutineListView: View {
	@StateObject private var viewModel = RoutineViewModel()

	var body: some View {
		NavigationView {
			List {
				ForEach(viewModel.routines) { routine in
					RoutineView(routine: routine, onDelete: {
						viewModel.deleteRoutine(routine)
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
				EditRoutineView(routine: Binding(
					get: { routine },
					set: { viewModel.updateRoutine($0) }
				))
			}
		}
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
