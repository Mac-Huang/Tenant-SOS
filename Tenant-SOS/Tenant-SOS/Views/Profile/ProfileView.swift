import SwiftUI
import StoreKit

struct ProfileView: View {
    @EnvironmentObject var userProfileManager: UserProfileManager
    @EnvironmentObject var storeManager: StoreManager
    @State private var showingSettings = false
    @State private var showingSubscription = false

    var body: some View {
        NavigationView {
            List {
                ProfileHeaderSection()

                ProfileDetailsSection()

                PreferencesSection()

                SubscriptionSection()

                SupportSection()

                LegalSection()
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingSubscription) {
                ProUpgradeView()
            }
        }
    }
}

struct ProfileHeaderSection: View {
    @EnvironmentObject var userProfileManager: UserProfileManager

    var body: some View {
        Section {
            HStack(spacing: 16) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome Back!")
                        .font(.headline)

                    Text("Home State: \(userProfileManager.homeState)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text("\(userProfileManager.housingStatus)")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(4)
                }

                Spacer()
            }
            .padding(.vertical, 8)
        }
    }
}

struct ProfileDetailsSection: View {
    @EnvironmentObject var userProfileManager: UserProfileManager

    var body: some View {
        Section("Profile Details") {
            DetailRow(label: "Home State", value: userProfileManager.homeState, icon: "house.fill")

            DetailRow(
                label: "Frequent States",
                value: userProfileManager.frequentStates.isEmpty ? "None" : userProfileManager.frequentStates.joined(separator: ", "),
                icon: "airplane"
            )

            DetailRow(label: "Housing Status", value: userProfileManager.housingStatus, icon: "building.2.fill")

            DetailRow(
                label: "Driver's License",
                value: userProfileManager.hasDriversLicense ? "Yes" : "No",
                icon: "car.fill"
            )

            DetailRow(label: "Employment", value: userProfileManager.employmentType, icon: "briefcase.fill")
        }
    }
}

struct PreferencesSection: View {
    @EnvironmentObject var userProfileManager: UserProfileManager
    @EnvironmentObject var notificationManager: NotificationManager

    var body: some View {
        Section("Preferences") {
            NavigationLink(destination: NotificationSettingsView()) {
                HStack {
                    Label("Notifications", systemImage: "bell.fill")
                    Spacer()
                    Text(userProfileManager.notificationPreference.capitalized)
                        .foregroundColor(.secondary)
                }
            }

            NavigationLink(destination: LocationSettingsView()) {
                Label("Location Services", systemImage: "location.fill")
            }

            NavigationLink(destination: PrivacySettingsView()) {
                Label("Privacy", systemImage: "lock.shield.fill")
            }

            NavigationLink(destination: AppearanceSettingsView()) {
                Label("Appearance", systemImage: "paintbrush.fill")
            }
        }
    }
}

struct SubscriptionSection: View {
    @EnvironmentObject var storeManager: StoreManager

    var body: some View {
        Section("Subscription") {
            if storeManager.isPro() {
                HStack {
                    Label("Pro Member", systemImage: "crown.fill")
                        .foregroundColor(.yellow)
                    Spacer()
                    Text("Active")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(4)
                }

                Button(action: {
                    // Manage subscription
                }) {
                    Text("Manage Subscription")
                        .foregroundColor(.blue)
                }
            } else {
                NavigationLink(destination: ProUpgradeView()) {
                    HStack {
                        Label("Upgrade to Pro", systemImage: "star.fill")
                            .foregroundColor(.yellow)
                        Spacer()
                        Text("$4.99/mo")
                            .foregroundColor(.secondary)
                    }
                }

                Button(action: {
                    Task {
                        await storeManager.restorePurchases()
                    }
                }) {
                    Text("Restore Purchases")
                        .foregroundColor(.blue)
                }
            }
        }
    }
}

struct SupportSection: View {
    var body: some View {
        Section("Support") {
            NavigationLink(destination: FAQView()) {
                Label("FAQ", systemImage: "questionmark.circle.fill")
            }

            Link(destination: URL(string: "mailto:support@tenantsos.com")!) {
                HStack {
                    Label("Contact Support", systemImage: "envelope.fill")
                    Spacer()
                    Image(systemName: "arrow.up.right.square")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            NavigationLink(destination: FeedbackView()) {
                Label("Send Feedback", systemImage: "bubble.left.fill")
            }

            Button(action: {
                requestAppReview()
            }) {
                Label("Rate App", systemImage: "star.fill")
                    .foregroundColor(.primary)
            }
        }
    }
}

struct LegalSection: View {
    var body: some View {
        Section("Legal") {
            Link(destination: URL(string: "https://tenantsos.com/privacy")!) {
                HStack {
                    Text("Privacy Policy")
                    Spacer()
                    Image(systemName: "arrow.up.right.square")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Link(destination: URL(string: "https://tenantsos.com/terms")!) {
                HStack {
                    Text("Terms of Service")
                    Spacer()
                    Image(systemName: "arrow.up.right.square")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            NavigationLink(destination: LicensesView()) {
                Text("Open Source Licenses")
            }

            HStack {
                Text("Version")
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    let icon: String

    var body: some View {
        HStack {
            Label(label, systemImage: icon)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

func requestAppReview() {
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
        SKStoreReviewController.requestReview(in: windowScene)
    }
}