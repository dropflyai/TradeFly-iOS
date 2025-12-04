//
//  LessonDetailView.swift
//  TradeFly AI
//

import SwiftUI

struct LessonDetailView: View {
    let module: LearningModule
    @Environment(\.dismiss) var dismiss
    @State private var hasCompleted = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(module.title)
                            .font(.title)
                            .fontWeight(.bold)

                        HStack {
                            Label(module.durationText, systemImage: "clock")
                            Text("•")
                            Label(module.difficulty.rawValue, systemImage: "chart.bar")
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }

                    // Video Placeholder
                    if module.videoURL != nil {
                        VideoPlaceholder()
                    }

                    // Content
                    Text(module.content)
                        .font(.body)
                        .lineSpacing(6)

                    // Mark Complete Button
                    if !module.isCompleted && !hasCompleted {
                        Button {
                            hasCompleted = true
                        } label: {
                            Text("Mark as Complete")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(15)
                        }
                    } else {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)

                            Text("Lesson Complete!")
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(15)
                    }

                    // Next Lesson
                    NextLessonCard()
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct VideoPlaceholder: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(Color(.systemGray5))
            .frame(height: 200)
            .overlay(
                VStack {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)

                    Text("Video Lesson")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            )
    }
}

struct NextLessonCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Next Lesson")
                .font(.headline)

            Text("Understanding EMAs")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Button {
                // Navigate to next lesson
            } label: {
                Text("Continue Learning →")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}
