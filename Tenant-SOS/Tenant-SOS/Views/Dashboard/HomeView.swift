import SwiftUI
import CoreLocation

struct HomeView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var dataController: DataController
    @EnvironmentObject var userProfileManager: UserProfileManager
    @EnvironmentObject var scrollCoordinator: ScrollCoordinator

    @State private var selectedCategory: String?
    @State private var showingStateComparison = false

    var body: some View {
        NavigationView {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 20) {
                        Color.clear
                            .frame(height: 1)
                            .id("top")

                        CurrentLocationCard()

                        if let currentState = locationManager.currentState {
                            let homeState = userProfileManager.homeState
                            if !homeState.isEmpty && currentState != homeState {
                                StateComparisonToggle(showingComparison: $showingStateComparison)
                            }
                        }

                        QuickAccessSection(selectedCategory: $selectedCategory)

                        if let currentStateCode = getStateCode() {
                            RecentLawsSection(stateCode: currentStateCode)
                        }

                        ImportantRemindersSection()
                    }
                    .padding()
                }
                .navigationTitle("Tenant SOS")
                .refreshable {
                    await refreshDataAsync()
                }
                .onChange(of: scrollCoordinator.scrollToTopTrigger) { _, _ in
                    withAnimation {
                        proxy.scrollTo("top", anchor: .top)
                    }
                }
            }
        }
    }

    private func getStateCode() -> String? {
        guard let currentStateName = locationManager.currentState else { return nil }

        // Try to match state name to code
        return dataController.fetchStates().first { state in
            state.name.lowercased() == currentStateName.lowercased() ||
            state.abbreviation == currentStateName
        }?.abbreviation
    }

    private func refreshDataAsync() async {
        // Refresh location
        await MainActor.run {
            locationManager.refreshLocation()
        }
        // Simulate refresh - pull to refresh
        try? await Task.sleep(nanoseconds: 500_000_000)
        // In production, reload data from server
        dataController.loadData()
    }
}

struct CurrentLocationCard: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var dataController: DataController

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
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                showingComparison.toggle()
            }
        }) {
            HStack {
                Image(systemName: "arrow.left.arrow.right")
                    .foregroundColor(.orange)
                Text("Compare with \(userProfileManager.homeState.isEmpty ? "Home State" : userProfileManager.homeState)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Image(systemName: showingComparison ? "chevron.up" : "chevron.down")
                    .font(.caption)
                    .rotationEffect(.degrees(showingComparison ? 180 : 0))
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(RoundedRectangle(cornerRadius: 12))

        if showingComparison {
            StateComparisonView()
                .padding(.top, 8)
        }
    }
}

struct StateComparisonView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var userProfileManager: UserProfileManager
    @EnvironmentObject var dataController: DataController

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let currentStateCode = getCurrentStateCode(),
               let homeStateCode = getHomeStateCode() {

                Text("Key Differences")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                // Compare minimum wage
                ComparisonRow(
                    category: "Minimum Wage",
                    current: getMinimumWage(for: currentStateCode),
                    home: getMinimumWage(for: homeStateCode)
                )

                // Compare security deposit
                ComparisonRow(
                    category: "Security Deposit",
                    current: getSecurityDeposit(for: currentStateCode),
                    home: getSecurityDeposit(for: homeStateCode)
                )

                // Compare speed limits
                ComparisonRow(
                    category: "Highway Speed Limit",
                    current: getSpeedLimit(for: currentStateCode),
                    home: getSpeedLimit(for: homeStateCode)
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private func getCurrentStateCode() -> String? {
        guard let currentStateName = locationManager.currentState else { return nil }
        return dataController.fetchStates().first { state in
            state.name == currentStateName || state.abbreviation == currentStateName
        }?.abbreviation
    }

    private func getHomeStateCode() -> String? {
        let homeState = userProfileManager.homeState
        if homeState.isEmpty { return nil }
        return dataController.fetchStates().first { state in
            state.name == homeState || state.abbreviation == homeState
        }?.abbreviation ?? homeState
    }

    private func getMinimumWage(for state: String) -> String {
        switch state {
        case "CA": return "$16.00/hr"
        case "TX": return "$7.25/hr"
        case "NY": return "$15.00/hr"
        case "FL": return "$12.00/hr"
        case "IL": return "$14.00/hr"
        default: return "Varies"
        }
    }

    private func getSecurityDeposit(for state: String) -> String {
        switch state {
        case "CA": return "2-3 months"
        case "TX": return "No limit"
        case "NY": return "1 month"
        case "FL": return "No limit"
        case "IL": return "Varies"
        default: return "Varies"
        }
    }

    private func getSpeedLimit(for state: String) -> String {
        switch state {
        case "CA": return "65-70 mph"
        case "TX": return "75-85 mph"
        case "NY": return "55-65 mph"
        case "FL": return "70 mph"
        case "IL": return "55-70 mph"
        default: return "Varies"
        }
    }
}

struct ComparisonRow: View {
    let category: String
    let current: String
    let home: String

    var body: some View {
        HStack {
            Text(category)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 100, alignment: .leading)

            VStack(alignment: .leading, spacing: 2) {
                Text("Current: \(current)")
                    .font(.caption2)
                    .fontWeight(.medium)
                Text("Home: \(home)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct QuickAccessSection: View {
    @Binding var selectedCategory: String?
    @EnvironmentObject var dataController: DataController

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    let categoryIcons = [
        "Tenant Rights": "house.fill",
        "Traffic Laws": "car.fill",
        "Employment": "briefcase.fill",
        "Tax": "dollarsign.circle.fill"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Access")
                .font(.headline)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(dataController.getCategories(), id: \.self) { category in
                    NavigationLink(destination: CategoryLawsView(category: category)) {
                        CategoryTileContent(
                            category: category,
                            icon: categoryIcons[category] ?? "folder.fill"
                        )
                    }
                }
            }
        }
    }
}

struct CategoryTileContent: View {
    let category: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)

            Text(category)
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 80)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct CategoryLawsView: View {
    let category: String
    @EnvironmentObject var dataController: DataController
    @EnvironmentObject var locationManager: LocationManager
    @State private var isRefreshing = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let stateCode = getCurrentStateCode() {
                    let laws = dataController.fetchLaws(for: stateCode, category: category)

                    if laws.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)

                            Text("No laws found for this category")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 100)
                    } else {
                        ForEach(laws, id: \.id) { law in
                            NavigationLink(destination: LawDetailView(law: law)) {
                                LawCard(law: law)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "location.slash")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)

                        Text("Location Not Detected")
                            .font(.headline)

                        Text("Enable location services to see laws for your current state")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        Button(action: {
                            // Trigger location refresh
                            isRefreshing = true
                            print("🔘 User tapped Refresh Location button")
                            locationManager.refreshLocation()

                            // Reset after delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                isRefreshing = false
                            }
                        }) {
                            HStack {
                                if isRefreshing {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                    Text("Refreshing...")
                                } else {
                                    Label("Refresh Location", systemImage: "location.fill")
                                }
                            }
                            .frame(minWidth: 180)
                            .padding()
                            .background(isRefreshing ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .disabled(isRefreshing)

                        // Show authorization status hint
                        if locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .restricted {
                            VStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundColor(.orange)
                                Text("Location permission denied")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("Open Settings > Privacy > Location Services > Tenant SOS")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                        }
                    }
                    .padding(.top, 50)
                }
            }
            .padding()
        }
        .navigationTitle(category)
        .navigationBarTitleDisplayMode(.large)
    }

    private func getCurrentStateCode() -> String? {
        guard let currentStateName = locationManager.currentState else { return nil }
        return dataController.fetchStates().first { state in
            state.name == currentStateName || state.abbreviation == currentStateName
        }?.abbreviation
    }
}

struct LawCard: View {
    let law: LawModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(law.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Text(law.summary)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)

            HStack {
                Label(law.category, systemImage: "tag.fill")
                    .font(.caption)
                    .foregroundColor(.blue)
                Spacer()
                Text(law.statute)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct LawDetailView: View {
    let law: LawModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(law.title)
                        .font(.title)
                        .fontWeight(.bold)

                    HStack {
                        Label(law.category, systemImage: "tag.fill")
                            .font(.subheadline)
                            .foregroundColor(.blue)

                        Spacer()

                        Text(law.stateCode)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                    }
                }

                Divider()

                // Summary
                VStack(alignment: .leading, spacing: 8) {
                    Text("Summary")
                        .font(.headline)

                    Text(law.summary)
                        .font(.body)
                        .foregroundColor(.secondary)
                }

                // Content
                VStack(alignment: .leading, spacing: 8) {
                    Text("Details")
                        .font(.headline)

                    Text(law.content)
                        .font(.body)
                        .lineSpacing(4)
                }

                // Statute
                VStack(alignment: .leading, spacing: 8) {
                    Text("Legal Reference")
                        .font(.headline)

                    HStack {
                        Image(systemName: "book.closed.fill")
                            .foregroundColor(.blue)

                        Text(law.statute)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct RecentLawsSection: View {
    let stateCode: String
    @EnvironmentObject var dataController: DataController

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Laws in \(getStateName())")
                    .font(.headline)
                Spacer()
                NavigationLink(destination: AllLawsListView(stateCode: stateCode)) {
                    Text("See All")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }

            VStack(spacing: 8) {
                ForEach(Array(dataController.fetchLaws(for: stateCode).prefix(3)), id: \.id) { law in
                    NavigationLink(destination: LawDetailsView(law: law)) {
                        LawRow(law: law)
                    }
                }
            }
        }
    }

    private func getStateName() -> String {
        dataController.fetchState(byCode: stateCode)?.name ?? stateCode
    }
}

struct LawRow: View {
    let law: LawModel
    @EnvironmentObject var dataController: DataController

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(law.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)

                    if dataController.isBookmarked(law) {
                        Image(systemName: "bookmark.fill")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                }

                Text(law.category)
                    .font(.caption2)
                    .foregroundColor(.blue)

                Text(law.summary)
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
    @EnvironmentObject var userProfileManager: UserProfileManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Important Reminders")
                .font(.headline)

            VStack(spacing: 8) {
                // These would be dynamic in production
                if userProfileManager.housingStatus == "renter" {
                    ReminderRow(
                        title: "Lease Renewal",
                        subtitle: "Check your lease expiration date",
                        icon: "doc.text",
                        color: .orange
                    )
                }

                if userProfileManager.hasDriversLicense == true {
                    ReminderRow(
                        title: "Vehicle Registration",
                        subtitle: "Renew annually in your state",
                        icon: "car",
                        color: .green
                    )
                }

                ReminderRow(
                    title: "Know Your Rights",
                    subtitle: "Review tenant laws for your state",
                    icon: "shield",
                    color: .blue
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

// Supporting Views

struct AllLawsListView: View {
    let stateCode: String
    @EnvironmentObject var dataController: DataController
    @State private var selectedCategory: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Category filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(title: "All", isSelected: selectedCategory == nil) {
                            selectedCategory = nil
                        }

                        ForEach(dataController.getCategories(), id: \.self) { category in
                            FilterChip(title: category, isSelected: selectedCategory == category) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // Laws list
                VStack(spacing: 8) {
                    ForEach(filteredLaws, id: \.id) { law in
                        NavigationLink(destination: LawDetailsView(law: law)) {
                            LawRow(law: law)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("\(getStateName()) Laws")
        .navigationBarTitleDisplayMode(.large)
    }

    private var filteredLaws: [LawModel] {
        if let category = selectedCategory {
            return dataController.fetchLaws(for: stateCode, category: category)
        } else {
            return dataController.fetchLaws(for: stateCode)
        }
    }

    private func getStateName() -> String {
        dataController.fetchState(byCode: stateCode)?.name ?? stateCode
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct LawDetailsView: View {
    let law: LawModel
    @EnvironmentObject var dataController: DataController
    @State private var isBookmarked = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(law.category)
                        .font(.caption)
                        .foregroundColor(.blue)
                        .textCase(.uppercase)

                    Text(law.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text(law.summary)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding()

                Divider()

                VStack(alignment: .leading, spacing: 16) {
                    Text("Details")
                        .font(.headline)

                    Text(law.content)
                        .font(.body)

                    HStack {
                        Image(systemName: "doc.text")
                            .foregroundColor(.secondary)
                        Text(law.statute)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 8)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    dataController.toggleBookmark(for: law)
                    isBookmarked.toggle()
                }) {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                }
            }
        }
        .onAppear {
            isBookmarked = dataController.isBookmarked(law)
        }
    }
}