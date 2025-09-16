import SwiftUI
import CoreData

struct HomeView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var dataController: DataController
    @EnvironmentObject var userProfileManager: UserProfileManager

    @State private var selectedCategory: LawCategory?
    @State private var showingStateComparison = false
    @State private var refreshing = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    CurrentLocationCard()

                    if locationManager.currentState != userProfileManager.homeState && !userProfileManager.homeState.isEmpty {
                        StateComparisonToggle(showingComparison: $showingStateComparison)
                    }

                    QuickAccessSection(selectedCategory: $selectedCategory)

                    if let currentState = locationManager.currentState {
                        RecentLawsSection(state: currentState)
                    }

                    ImportantRemindersSection()
                }
                .padding()
            }
            .navigationTitle("Tenant SOS")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        refreshData()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .rotationEffect(.degrees(refreshing ? 360 : 0))
                            .animation(refreshing ? Animation.linear(duration: 1).repeatForever(autoreverses: false) : .default, value: refreshing)
                    }
                }
            }
            .refreshable {
                await refreshDataAsync()
            }
        }
    }

    private func refreshData() {
        refreshing = true
        Task {
            await refreshDataAsync()
            refreshing = false
        }
    }

    private func refreshDataAsync() async {

        await Task.sleep(1_000_000_000)
    }
}

struct CurrentLocationCard: View {
    @EnvironmentObject var locationManager: LocationManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(.blue)
                Text("Current Location")
                    .font(.headline)
                Spacer()
            }

            if let state = locationManager.currentState,
               let city = locationManager.currentCity {
                Text("\(city), \(state)")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Laws and regulations for this area are now active")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("Detecting location...")
                    .font(.body)
                    .foregroundColor(.secondary)
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(0.8)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct StateComparisonToggle: View {
    @Binding var showingComparison: Bool
    @EnvironmentObject var userProfileManager: UserProfileManager
    @EnvironmentObject var locationManager: LocationManager

    var body: some View {
        Button(action: {
            showingComparison.toggle()
        }) {
            HStack {
                Image(systemName: "arrow.left.arrow.right")
                    .foregroundColor(.orange)
                Text("Compare with \(userProfileManager.homeState)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Image(systemName: showingComparison ? "chevron.up" : "chevron.down")
                    .font(.caption)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct QuickAccessSection: View {
    @Binding var selectedCategory: LawCategory?
    @EnvironmentObject var dataController: DataController

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Access")
                .font(.headline)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(dataController.fetchCategories(), id: \.self) { category in
                    CategoryTile(category: category, isSelected: selectedCategory == category) {
                        selectedCategory = category
                    }
                }
            }
        }
    }
}

struct CategoryTile: View {
    let category: LawCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: category.icon ?? "folder.fill")
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .blue)

                Text(category.name ?? "")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct RecentLawsSection: View {
    let state: String
    @EnvironmentObject var dataController: DataController

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("New in \(state)")
                    .font(.headline)
                Spacer()
                NavigationLink(destination: AllLawsView(state: state)) {
                    Text("See All")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }

            VStack(spacing: 8) {
                ForEach(dataController.fetchLaws(for: state).prefix(3), id: \.self) { law in
                    NavigationLink(destination: LawDetailView(law: law)) {
                        LawRow(law: law)
                    }
                }
            }
        }
    }
}

struct LawRow: View {
    let law: Law

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(law.title ?? "")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)

                Text(law.lawDescription ?? "")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct ImportantRemindersSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Important Reminders")
                .font(.headline)

            VStack(spacing: 8) {
                ReminderRow(
                    title: "Lease Renewal",
                    subtitle: "Due in 30 days",
                    icon: "doc.text",
                    color: .orange
                )

                ReminderRow(
                    title: "Vehicle Registration",
                    subtitle: "Expires in 2 weeks",
                    icon: "car",
                    color: .red
                )
            }
        }
    }
}

struct ReminderRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "bell.badge")
                .font(.caption)
                .foregroundColor(color)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}