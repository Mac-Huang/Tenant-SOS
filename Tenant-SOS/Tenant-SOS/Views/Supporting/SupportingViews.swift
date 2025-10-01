import SwiftUI
import StoreKit
import CoreLocation

// MARK: - Settings View
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("selectedTheme") private var selectedTheme = "system"
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true

    var body: some View {
        NavigationView {
            List {
                Section("Appearance") {
                    Picker("Theme", selection: $selectedTheme) {
                        Text("System").tag("system")
                        Text("Light").tag("light")
                        Text("Dark").tag("dark")
                    }
                }

                Section("Notifications") {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                }

                Section("Data") {
                    Button("Clear Cache") {
                        // Clear cache
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
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


// MARK: - Notification Settings View
struct NotificationSettingsView: View {
    @EnvironmentObject var userProfileManager: UserProfileManager
    @EnvironmentObject var notificationManager: NotificationManager
    @State private var stateChangeNotifications = true
    @State private var lawUpdateNotifications = true
    @State private var documentReminders = true

    var body: some View {
        Form {
            Section("Notification Types") {
                Toggle("State Change Alerts", isOn: $stateChangeNotifications)
                Toggle("Law Updates", isOn: $lawUpdateNotifications)
                Toggle("Document Reminders", isOn: $documentReminders)
            }

            Section("Frequency") {
                Picker("Update Frequency", selection: $userProfileManager.notificationPreference) {
                    Text("Immediate").tag("immediate")
                    Text("Daily Digest").tag("daily")
                    Text("Weekly Summary").tag("weekly")
                    Text("Never").tag("never")
                }
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Location Settings View
struct LocationSettingsView: View {
    @EnvironmentObject var locationManager: LocationManager

    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Location Services")
                    Spacer()
                    Text(statusText)
                        .foregroundColor(.secondary)
                }

                if locationManager.authorizationStatus == .denied {
                    Text("Location services are disabled. Enable them in Settings to get location-based laws.")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Button("Open Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                }
            }

            if let state = locationManager.currentState,
               let city = locationManager.currentCity {
                Section("Current Location") {
                    HStack {
                        Text("City")
                        Spacer()
                        Text(city)
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("State")
                        Spacer()
                        Text(state)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Location Services")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var statusText: String {
        switch locationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            return "Enabled"
        case .denied, .restricted:
            return "Disabled"
        case .notDetermined:
            return "Not Set"
        @unknown default:
            return "Unknown"
        }
    }
}

// MARK: - Privacy Settings View
struct PrivacySettingsView: View {
    @State private var shareAnalytics = true
    @State private var shareCrashData = true

    var body: some View {
        Form {
            Section("Data Sharing") {
                Toggle("Share Analytics", isOn: $shareAnalytics)
                Toggle("Share Crash Reports", isOn: $shareCrashData)
            }

            Section("Data Management") {
                Button("Delete All Data") {
                    // Delete data
                }
                .foregroundColor(.red)

                Button("Export My Data") {
                    // Export data
                }
            }

            Section {
                Link("Privacy Policy", destination: URL(string: "https://tenantsos.com/privacy")!)
            }
        }
        .navigationTitle("Privacy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Appearance Settings View
struct AppearanceSettingsView: View {
    @AppStorage("selectedTheme") private var selectedTheme = "system"
    @AppStorage("useLargeText") private var useLargeText = false

    var body: some View {
        Form {
            Section("Theme") {
                Picker("App Theme", selection: $selectedTheme) {
                    Text("System").tag("system")
                    Text("Light").tag("light")
                    Text("Dark").tag("dark")
                }
                .pickerStyle(SegmentedPickerStyle())
            }

            Section("Text") {
                Toggle("Use Large Text", isOn: $useLargeText)
            }
        }
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - FAQ View
struct FAQView: View {
    struct FAQItem: Identifiable {
        let id = UUID()
        let question: String
        let answer: String
    }

    let faqs = [
        FAQItem(question: "How does location detection work?", answer: "The app uses your device's GPS to detect which state you're in and automatically shows relevant laws."),
        FAQItem(question: "Are the laws up to date?", answer: "We update our database regularly to ensure all laws are current and accurate."),
        FAQItem(question: "Can I use documents in court?", answer: "Our documents are for informational purposes. Always consult with a lawyer for legal advice."),
        FAQItem(question: "Is my data secure?", answer: "Yes, all your data is encrypted and stored securely. We never share your personal information."),
        FAQItem(question: "How do I cancel my subscription?", answer: "You can cancel anytime through your iPhone Settings > Apple ID > Subscriptions.")
    ]

    var body: some View {
        List(faqs) { item in
            DisclosureGroup(item.question) {
                Text(item.answer)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            }
        }
        .navigationTitle("FAQ")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Feedback View
struct FeedbackView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var feedbackText = ""
    @State private var feedbackType = "suggestion"

    var body: some View {
        NavigationView {
            Form {
                Section("Feedback Type") {
                    Picker("Type", selection: $feedbackType) {
                        Text("Suggestion").tag("suggestion")
                        Text("Bug Report").tag("bug")
                        Text("Feature Request").tag("feature")
                        Text("Other").tag("other")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Section("Your Feedback") {
                    TextEditor(text: $feedbackText)
                        .frame(height: 200)
                }

                Section {
                    Button("Send Feedback") {
                        // Send feedback
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(feedbackText.isEmpty)
                }
            }
            .navigationTitle("Send Feedback")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Licenses View
struct LicensesView: View {
    let licenses = [
        ("Firebase", "Apache License 2.0"),
        ("PDFKit", "Apple SDK License"),
        ("SwiftUI", "Apple SDK License")
    ]

    var body: some View {
        List(licenses, id: \.0) { license in
            HStack {
                Text(license.0)
                Spacer()
                Text(license.1)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Open Source Licenses")
        .navigationBarTitleDisplayMode(.inline)
    }
}