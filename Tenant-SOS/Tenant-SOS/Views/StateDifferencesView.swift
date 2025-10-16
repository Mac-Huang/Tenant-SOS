import SwiftUI

struct StateDifferencesView: View {
    let fromState: String
    let toState: String
    @State private var selectedCategory: LawCategoryType? = nil
    @State private var differences: [LawComparison] = []
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    StateComparisonHeader(fromState: fromState, toState: toState)

                    // Critical Differences Alert
                    if let criticalDiffs = getCriticalDifferences() {
                        CriticalDifferencesCard(differences: criticalDiffs)
                    }

                    // Category Filter
                    CategoryFilterView(selectedCategory: $selectedCategory)

                    // Differences List
                    DifferencesListView(
                        differences: filteredDifferences,
                        fromState: fromState,
                        toState: toState
                    )
                }
                .padding()
            }
            .navigationTitle("Law Differences")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            loadDifferences()
        }
    }

    private func loadDifferences() {
        differences = StateLawsDatabase.getKeyDifferences(
            from: fromState,
            to: toState,
            categories: selectedCategory != nil ? [selectedCategory!] : nil
        )
    }

    private var filteredDifferences: [LawComparison] {
        if let category = selectedCategory {
            return differences.filter { $0.category == category }
        }
        return differences
    }

    private func getCriticalDifferences() -> [LawComparison]? {
        let critical = differences.filter { $0.importance == .critical }
        return critical.isEmpty ? nil : critical
    }
}

// MARK: - State Comparison Header
struct StateComparisonHeader: View {
    let fromState: String
    let toState: String

    var body: some View {
        HStack(spacing: 20) {
            // From State
            VStack {
                Image(systemName: "location.circle")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
                Text(StateDatabase.getState(byCode: fromState)?.name ?? fromState)
                    .font(.headline)
                Text("Previous")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Arrow
            Image(systemName: "arrow.right.circle.fill")
                .font(.title)
                .foregroundColor(.blue)

            // To State
            VStack {
                Image(systemName: "location.fill.viewfinder")
                    .font(.largeTitle)
                    .foregroundColor(.blue)
                Text(StateDatabase.getState(byCode: toState)?.name ?? toState)
                    .font(.headline)
                Text("Current")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Critical Differences Alert
struct CriticalDifferencesCard: View {
    let differences: [LawComparison]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                Text("Critical Differences")
                    .font(.headline)
                    .foregroundColor(.red)
            }

            ForEach(differences, id: \.lawTitle) { diff in
                HStack(alignment: .top) {
                    Image(systemName: diff.category.icon)
                        .foregroundColor(.red)
                        .frame(width: 20)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(diff.lawTitle)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text("\(diff.toState): \(diff.toValue)")
                            .font(.caption)
                            .foregroundColor(.primary)
                        Text("Was: \(diff.fromValue)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }

                    Spacer()
                }
            }
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.red.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Category Filter
struct CategoryFilterView: View {
    @Binding var selectedCategory: LawCategoryType?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // All Categories
                CategoryChip(
                    title: "All",
                    icon: "square.grid.2x2",
                    isSelected: selectedCategory == nil,
                    action: { selectedCategory = nil }
                )

                // Individual Categories
                ForEach(LawCategoryType.allCases, id: \.self) { category in
                    CategoryChip(
                        title: category.rawValue,
                        icon: category.icon,
                        isSelected: selectedCategory == category,
                        action: { selectedCategory = category }
                    )
                }
            }
        }
    }
}

struct CategoryChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.blue : Color(.systemGray5))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(15)
        }
    }
}

// MARK: - Differences List
struct DifferencesListView: View {
    let differences: [LawComparison]
    let fromState: String
    let toState: String

    var body: some View {
        VStack(spacing: 12) {
            if differences.isEmpty {
                NoDifferencesView()
            } else {
                ForEach(differences, id: \.lawTitle) { diff in
                    DifferenceCard(difference: diff)
                }
            }
        }
    }
}

struct DifferenceCard: View {
    let difference: LawComparison

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Image(systemName: difference.category.icon)
                    .foregroundColor(importanceColor(difference.importance))
                Text(difference.category.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                ImportanceBadge(level: difference.importance)
            }

            // Law Title
            Text(difference.lawTitle)
                .font(.headline)

            // Description
            Text(difference.description)
                .font(.caption)
                .foregroundColor(.secondary)

            // Comparison
            HStack(spacing: 16) {
                // Previous State
                VStack(alignment: .leading, spacing: 4) {
                    Text(difference.fromState)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(difference.fromValue)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                Image(systemName: "arrow.right")
                    .foregroundColor(.blue)

                // New State
                VStack(alignment: .leading, spacing: 4) {
                    Text(difference.toState)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(difference.toValue)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }

                Spacer()
            }
            .padding(.top, 4)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }

    private func importanceColor(_ level: ImportanceLevel) -> Color {
        switch level {
        case .critical: return .red
        case .high: return .orange
        case .medium: return .blue
        case .low: return .gray
        }
    }
}

struct ImportanceBadge: View {
    let level: ImportanceLevel

    var body: some View {
        Text(badgeText)
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(badgeColor.opacity(0.2))
            .foregroundColor(badgeColor)
            .cornerRadius(8)
    }

    private var badgeText: String {
        switch level {
        case .critical: return "CRITICAL"
        case .high: return "HIGH"
        case .medium: return "MEDIUM"
        case .low: return "LOW"
        }
    }

    private var badgeColor: Color {
        switch level {
        case .critical: return .red
        case .high: return .orange
        case .medium: return .blue
        case .low: return .gray
        }
    }
}

struct NoDifferencesView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.green)
            Text("No Major Differences")
                .font(.headline)
            Text("Laws are similar between these states")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(40)
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Preview
struct StateDifferencesView_Previews: PreviewProvider {
    static var previews: some View {
        StateDifferencesView(fromState: "CA", toState: "TX")
    }
}