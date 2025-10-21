import SwiftUI
import StoreKit

struct ProfileView: View {
    @EnvironmentObject var userProfileManager: UserProfileManager
    @State private var showingSettings = false
    @State private var showingEditProfile = false

    var body: some View {
        NavigationView {
            List {
                ProfileHeaderSection()

                ProfileDetailsSection()

                PreferencesSection()

                SupportSection()

                LegalSection()
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingEditProfile = true
                    }) {
                        Text("Edit")
                            .foregroundColor(.blue)
                    }
                }

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
            .sheet(isPresented: $showingEditProfile) {
                EditableProfileView()
            }
        }
    }
}

struct ProfileHeaderSection: View {
    @EnvironmentObject var userProfileManager: UserProfileManager
    @State private var profileImage: UIImage?

    var body: some View {
        Section {
            HStack(spacing: 16) {
                if let profileImage = profileImage {
                    Image(uiImage: profileImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
                } else {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                }


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
        .onAppear {
            loadProfileImage()
        }
        .onReceive(NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)) { _ in
            loadProfileImage()
        }
    }

    private func loadProfileImage() {
        if let imageData = UserDefaults.standard.data(forKey: "profileImage"),
           let image = UIImage(data: imageData) {
            profileImage = image
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
                HStack {
                    Label("Rate App", systemImage: "star.fill")
                    Spacer()
                }
                .contentShape(Rectangle())
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
        if #available(iOS 18.0, *) {
            // Suppress deprecation warning - will update to new API when minimum iOS version is 18
            #if compiler(>=6.0)
            #warning("Update to use AppStore.requestReview(in:) when minimum iOS version is 18.0")
            #endif
        }
        SKStoreReviewController.requestReview(in: windowScene)
    }
}