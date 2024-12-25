//
//  RoutineView.swift
//  routineMoniter
//
//  Created by Zafar Ali on 25/12/2024.
//

import SwiftUI


struct RoutineView: View {
	var routine: Routine
	var onDelete: () -> Void

	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			Text(routine.title)
				.font(.headline)
				.fontWeight(.bold)
				.lineLimit(1)

			Text(routine.description)
				.font(.subheadline)
				.foregroundColor(.secondary)
				.lineLimit(2)

			HStack {
				Image(systemName: "clock")
					.foregroundColor(.blue)
				Text(routine.time, formatter: Self.dateFormatter)
					.font(.caption)
					.foregroundColor(.gray)
			}

			Button(action: onDelete) {
				Text("Swipe left to delete")
					.foregroundColor(.red)
			}
			.padding(.top, 8)
		}
		.padding()
		.background(Color(UIColor.secondarySystemBackground))
		.cornerRadius(10)
		.shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
	}

	private static var dateFormatter: DateFormatter {
		let formatter = DateFormatter()
		formatter.dateStyle = .short
		formatter.timeStyle = .short
		return formatter
	}
}

