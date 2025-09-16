import SwiftUI
import StoreKit

// MARK: - Law Detail View
struct LawDetailView: View {
    let law: Law
    @State private var isBookmarked = false
    @EnvironmentObject var dataController: DataController

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Label(law.category?.name ?? "", systemImage: law.category?.icon ?? "folder")
                            .font(.caption)
                            .foregroundColor(.blue)

                        Spacer()

                        Button(action: {
                            toggleBookmark()
                        }) {
                            Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                                .foregroundColor(.blue)
                        }
                    }

                    Text(law.title ?? "")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text(law.state?.name ?? "")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()

                VStack(alignment: .leading, spacing: 16) {
                    Text("Description")
                        .font(.headline)

                    Text(law.lawDescription ?? "")
                        .font(.body)

                    if let statute = law.statute {
                        Text("Statute Reference")
                            .font(.headline)
                            .padding(.top)

                        Text(statute)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }

                    if let effectiveDate = law.effectiveDate {
                        Text("Effective Date")
                            .font(.headline)
                            .padding(.top)

                        Text(effectiveDate, style: .date)
                            .font(.body)
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Law Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func toggleBookmark() {
        if isBookmarked {
            // Remove bookmark
        } else {
            dataController.addBookmark(for: law)
        }
        isBookmarked.toggle()
    }
}

// MARK: - All Laws View
struct AllLawsView: View {
    let state: String
    @EnvironmentObject var dataController: DataController
    @State private var selectedCategory: String = "All"

    var body: some View {
        List {
            ForEach(filteredLaws, id: \\.self) { law in
                NavigationLink(destination: LawDetailView(law: law)) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(law.title ?? "")
                            .font(.headline)

                        Text(law.lawDescription ?? "")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)

                        HStack {
                            Label(law.category?.name ?? "", systemImage: law.category?.icon ?? "folder")
                                .font(.caption2)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("\\(state) Laws")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("All") { selectedCategory = "All" }
                    ForEach(dataController.fetchCategories(), id: \\.self) { category in
                        Button(category.name ?? "") {
                            selectedCategory = category.name ?? ""
                        }
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
            }
        }
    }

    var filteredLaws: [Law] {
        if selectedCategory == "All" {
            return dataController.fetchLaws(for: state)
        } else {
            return dataController.fetchLaws(for: state, category: selectedCategory)
        }
    }
}

// MARK: - Settings Views
struct SettingsView: View {
    @Environment(\\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List {
                Section("Account") {
                    NavigationLink(destination: AccountSettingsView()) {
                        Label("Account Settings", systemImage: "person.circle")
                    }

                    NavigationLink(destination: DataManagementView()) {
                        Label("Data Management", systemImage: "externaldrive")
                    }
                }

                Section("App") {
                    NavigationLink(destination: AppearanceSettingsView()) {
                        Label("Appearance", systemImage: "paintbrush")
                    }

                    NavigationLink(destination: NotificationSettingsView()) {
                        Label("Notifications", systemImage: "bell")
                    }

                    NavigationLink(destination: LocationSettingsView()) {
                        Label("Location", systemImage: "location")
                    }
                }

                Section("About") {
                    NavigationLink(destination: AboutView()) {
                        Label("About Tenant SOS", systemImage: "info.circle")
                    }

                    Link(destination: URL(string: "https://tenantsos.com")!) {
                        HStack {
                            Label("Website", systemImage: "globe")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
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

struct NotificationSettingsView: View {
    @EnvironmentObject var userProfileManager: UserProfileManager
    @State private var stateChangeAlerts = true
    @State private var documentReminders = true
    @State private var lawUpdates = true
    @State private var dailyDigest = false
    @State private var digestTime = Date()

    var body: some View {
        Form {
            Section("Alert Types") {
                Toggle("State Change Alerts", isOn: $stateChangeAlerts)
                Toggle("Document Reminders", isOn: $documentReminders)
                Toggle("Law Updates", isOn: $lawUpdates)
            }

            Section("Daily Digest") {
                Toggle("Enable Daily Digest", isOn: $dailyDigest)

                if dailyDigest {
                    DatePicker("Delivery Time", selection: $digestTime, displayedComponents: .hourAndMinute)
                }
            }

            Section("Frequency") {
                Picker("Notification Preference", selection: $userProfileManager.notificationPreference) {
                    Text("Immediate").tag("immediate")
                    Text("Daily").tag("daily")
                    Text("Weekly").tag("weekly")
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
        .navigationTitle("Notifications")
    }
}

struct LocationSettingsView: View {
    @EnvironmentObject var locationManager: LocationManager
    @State private var backgroundTracking = true
    @State private var significantLocationOnly = false

    var body: some View {
        Form {
            Section("Permissions") {
                HStack {
                    Text("Location Access")
                    Spacer()
                    Text(locationManager.authorizationStatus == .authorizedAlways ? "Always" : "When In Use")
                        .foregroundColor(.secondary)
                }

                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            }

            Section("Tracking Options") {
                Toggle("Background Tracking", isOn: $backgroundTracking)
                Toggle("Significant Changes Only", isOn: $significantLocationOnly)
            }

            Section("Battery Usage") {
                Text("Location tracking may affect battery life. Enable 'Significant Changes Only' to reduce battery impact.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Location Services")
    }
}

struct AppearanceSettingsView: View {
    @AppStorage("selectedTheme") private var selectedTheme = "system"
    @AppStorage("useLargeText") private var useLargeText = false

    var body: some View {
        Form {
            Section("Theme") {
                Picker("Appearance", selection: $selectedTheme) {
                    Text("System").tag("system")
                    Text("Light").tag("light")
                    Text("Dark").tag("dark")
                }
                .pickerStyle(SegmentedPickerStyle())
            }

            Section("Text Size") {
                Toggle("Use Large Text", isOn: $useLargeText)
            }
        }
        .navigationTitle("Appearance")
    }
}

struct PrivacySettingsView: View {
    @State private var analyticsEnabled = true
    @State private var crashReportsEnabled = true

    var body: some View {
        Form {
            Section("Data Collection") {
                Toggle("Analytics", isOn: $analyticsEnabled)
                Toggle("Crash Reports", isOn: $crashReportsEnabled)
            }

            Section("Privacy") {
                Link("Privacy Policy", destination: URL(string: "https://tenantsos.com/privacy")!)
                Link("Terms of Service", destination: URL(string: "https://tenantsos.com/terms")!)
            }

            Section {
                Button("Delete All Data", role: .destructive) {
                    // Handle data deletion
                }
            }
        }
        .navigationTitle("Privacy")
    }
}

// MARK: - Supporting Views
struct FAQView: View {
    var body: some View {
        List {
            FAQItem(
                question: "How does location tracking work?",
                answer: "Tenant SOS uses your device's GPS to detect your current state and show relevant laws. Your location data stays on your device."
            )

            FAQItem(
                question: "Are the generated documents legally binding?",
                answer: "Documents generated by Tenant SOS are templates for informational purposes. Always consult with a legal professional for binding agreements."
            )

            FAQItem(
                question: "How often are laws updated?",
                answer: "We update our database monthly or whenever significant law changes occur. Pro users receive priority updates."
            )

            FAQItem(
                question: "Can I use the app offline?",
                answer: "Yes, previously viewed laws and generated documents are available offline. New content requires an internet connection."
            )
        }
        .navigationTitle("FAQ")
    }
}

struct FAQItem: View {
    let question: String
    let answer: String
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: {
                isExpanded.toggle()
            }) {
                HStack {
                    Text(question)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            if isExpanded {
                Text(answer)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
        .padding(.vertical, 4)
    }
}

struct FeedbackView: View {
    @State private var feedbackType = "Bug Report"
    @State private var feedbackText = ""
    @Environment(\\.dismiss) private var dismiss

    let feedbackTypes = ["Bug Report", "Feature Request", "General Feedback"]

    var body: some View {
        Form {
            Section("Feedback Type") {
                Picker("Type", selection: $feedbackType) {
                    ForEach(feedbackTypes, id: \\.self) { type in
                        Text(type).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }

            Section("Your Feedback") {
                TextEditor(text: $feedbackText)
                    .frame(minHeight: 150)
            }

            Section {
                Button("Send Feedback") {
                    // Send feedback
                    dismiss()
                }
                .disabled(feedbackText.isEmpty)
            }
        }
        .navigationTitle("Send Feedback")
    }
}

struct LicensesView: View {
    var body: some View {
        List {
            Text("Firebase - Apache License 2.0")
            Text("Kingfisher - MIT License")
            Text("SwiftUI - Apple License")
        }
        .navigationTitle("Open Source Licenses")
    }
}

struct AccountSettingsView: View {
    var body: some View {
        Form {
            Section("Account") {
                Text("Account management coming soon")
            }
        }
        .navigationTitle("Account Settings")
    }
}

struct DataManagementView: View {
    var body: some View {
        Form {
            Section("Data") {
                Button("Export My Data") {
                    // Handle data export
                }

                Button("Delete All Data", role: .destructive) {
                    // Handle data deletion
                }
            }
        }
        .navigationTitle("Data Management")
    }
}

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: "shield.checkered")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)

                Text("Tenant SOS")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Version \\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("Your Personal Legal Assistant")
                    .font(.body)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Tenant SOS helps you navigate legal complexities with confidence by providing location-aware legal information and document generation tools.")
                        .font(.body)

                    Text("Created with care to make legal information accessible to everyone.")
                        .font(.body)
                }
                .padding()

                HStack(spacing: 20) {
                    Link("Website", destination: URL(string: "https://tenantsos.com")!)
                    Link("Support", destination: URL(string: "mailto:support@tenantsos.com")!)
                    Link("Twitter", destination: URL(string: "https://twitter.com/tenantsos")!)
                }
                .font(.subheadline)
            }
            .padding()
        }
        .navigationTitle("About")
    }
}