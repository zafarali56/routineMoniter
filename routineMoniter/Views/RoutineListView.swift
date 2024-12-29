import SwiftUI

struct RoutineListView: View {
	@StateObject private var viewModel = RoutineViewModel()

	
	@State private var isNavigatingToNewRoutine = false
	@State private var newlyCreatedRoutine: RoutineEntity?

	var body: some View {
		NavigationView {
			List {
				ForEach(viewModel.routines) { routine in
					NavigationLink(
						destination: EditRoutineView(routine: routine)
							.environmentObject(viewModel)
					) {
					
						VStack(alignment: .leading) {
							Text(routine.title ?? "No Title")
								.font(.headline)
							
							Text("Swipe left to delete")
								.font(.caption)
								.foregroundColor(.gray)
						}
					}
				}
				.onDelete(perform: viewModel.removeRoutine)
			}
			.navigationTitle("Routines")
			.toolbar {
				Button("Add") {
			
					let routine = viewModel.addRoutine()
					newlyCreatedRoutine = routine
					isNavigatingToNewRoutine = true
				}
			}
		
			.background(
				NavigationLink(
					destination: Group {
						if let routine = newlyCreatedRoutine {
							EditRoutineView(routine: routine)
								.environmentObject(viewModel)
						} else {
							EmptyView()
						}
					},
					isActive: $isNavigatingToNewRoutine
				) {
					EmptyView()
				}
				.hidden()
			)
		}
	}
}

// Quick Preview
#Preview {
	RoutineListView()
}


struct EditRoutineView: View {
	@EnvironmentObject var viewModel: RoutineViewModel
	@Environment(\.presentationMode) var presentationMode

	@State private var updatedTitle: String
	@State private var updatedDescription: String
	@State private var updatedTime: Date

	let routine: RoutineEntity

	init(routine: RoutineEntity) {
		self.routine = routine
		_updatedTitle = State(initialValue: routine.title ?? "")
		_updatedDescription = State(initialValue: routine.routineDescription ?? "")
		_updatedTime = State(initialValue: routine.time ?? Date())
	}

	var body: some View {
		Form {
			Section(header: Text("Title")) {
				TextField("Enter title", text: $updatedTitle)
			}

			Section(header: Text("Description")) {
				TextField("Enter description", text: $updatedDescription)
			}

			Section(header: Text("Time")) {
				DatePicker(
					"Pick a time",
					selection: $updatedTime,
					displayedComponents: .hourAndMinute
				)
			}

			Section {
				Button(action: saveAndDismiss) {
					Text("Save Changes")
						.frame(maxWidth: .infinity, alignment: .center)
				}
			}
		}
		.navigationTitle("Edit Routine")
		.navigationBarTitleDisplayMode(.inline)
	}

	private func saveAndDismiss() {
		viewModel.updateRoutine(
			routine,
			title: updatedTitle,
			description: updatedDescription,
			time: updatedTime
		)
		presentationMode.wrappedValue.dismiss()
	}
}
