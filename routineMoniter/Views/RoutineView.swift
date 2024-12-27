import SwiftUI

struct RoutineView: View {
	var routine: RoutineEntity

	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			Text(routine.title ?? "Untitled")
				.font(.headline)
				.fontWeight(.bold)
				.lineLimit(1)

			Text(routine.routineDescription ?? "No description")
				.font(.subheadline)
				.foregroundColor(.secondary)
				.lineLimit(2)

			HStack {
				Image(systemName: "clock")
					.foregroundColor(.blue)
				Text(routine.time ?? Date(), style: .time)
					.font(.caption)
					.foregroundColor(.gray)
			}

			Text("Swipe right to delete")
				.font(.footnote)
				.foregroundColor(.gray)
				.padding(.top, 8)
		}
		.padding()
		.background(Color(UIColor.secondarySystemBackground))
		.cornerRadius(10)
		.shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
	}
}
