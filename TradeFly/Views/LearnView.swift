//
//  LearnView.swift
//  TradeFly AI
//

import SwiftUI

struct LearnView: View {
    @State private var modules: [LearningModule] = [] // Start empty - fetch from database
    @State private var selectedModule: LearningModule?
    @State private var isLoading = false

    var modulesByCategory: [LearningCategory: [LearningModule]] {
        Dictionary(grouping: modules) { $0.category }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Progress Card
                    ProgressOverviewCard(modules: modules)

                    // Categories
                    ForEach(LearningCategory.allCases, id: \.self) { category in
                        if let categoryModules = modulesByCategory[category], !categoryModules.isEmpty {
                            CategorySection(
                                category: category,
                                modules: categoryModules,
                                selectedModule: $selectedModule
                            )
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Learn")
            .sheet(item: $selectedModule) { module in
                LessonDetailView(module: module)
            }
        }
    }
}

// MARK: - Progress Overview Card
struct ProgressOverviewCard: View {
    let modules: [LearningModule]

    var completedCount: Int {
        modules.filter { $0.isCompleted }.count
    }

    var progress: Double {
        Double(completedCount) / Double(modules.count)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📚 Your Progress")
                .font(.headline)

            HStack {
                Text("\(completedCount)/\(modules.count) lessons")
                    .font(.title3)
                    .fontWeight(.bold)

                Spacer()

                Text("\(Int(progress * 100))%")
                    .font(.title3)
                    .foregroundColor(.blue)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 12)

                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * CGFloat(progress), height: 12)
                }
            }
            .frame(height: 12)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Category Section
struct CategorySection: View {
    let category: LearningCategory
    let modules: [LearningModule]
    @Binding var selectedModule: LearningModule?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: category.icon)
                    .foregroundColor(.blue)

                Text(category.rawValue)
                    .font(.headline)
            }

            ForEach(modules) { module in
                LessonRow(module: module)
                    .onTapGesture {
                        selectedModule = module
                    }
            }
        }
    }
}

// MARK: - Lesson Row
struct LessonRow: View {
    let module: LearningModule

    var body: some View {
        HStack(spacing: 12) {
            // Status Icon
            Image(systemName: module.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(module.isCompleted ? .green : .gray)
                .font(.title3)

            VStack(alignment: .leading, spacing: 4) {
                Text(module.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                HStack {
                    Text(module.progressStars)
                        .font(.caption)

                    Text("•")
                        .foregroundColor(.secondary)

                    Text(module.durationText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

#Preview {
    LearnView()
}
