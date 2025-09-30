import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0

    var body: some View {
        ZStack {
            TabView(selection: $currentPage) {
            WelcomeView(currentPage: $currentPage)
                .tag(0)

            LocationPermissionView(currentPage: $currentPage)
                .tag(1)

            NotificationPermissionView(currentPage: $currentPage)
                .tag(2)

            ProfileSetupView(hasCompletedOnboarding: $hasCompletedOnboarding)
                .tag(3)
        }
        .tabViewStyle(PageTabViewStyle())
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        .animation(.easeInOut, value: currentPage)

            // Skip button for testing
            VStack {
                HStack {
                    Spacer()
                    Button("Skip All") {
                        hasCompletedOnboarding = true
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.red.opacity(0.8))
                    .cornerRadius(8)
                }
                Spacer()
            }
            .padding()
        }
    }
}

struct WelcomeView: View {
    @Binding var currentPage: Int

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Image(systemName: "shield.checkered")
                .font(.system(size: 80))
                .foregroundColor(.blue)
                .padding()

            VStack(spacing: 16) {
                Text("Welcome to Tenant SOS")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Your Personal Legal Assistant")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }

            VStack(alignment: .leading, spacing: 20) {
                FeatureRow(
                    icon: "location.fill",
                    title: "Location-Based Laws",
                    description: "Get relevant laws based on your current location"
                )

                FeatureRow(
                    icon: "doc.text.fill",
                    title: "Document Generator",
                    description: "Create legal documents with ease"
                )

                FeatureRow(
                    icon: "bell.fill",
                    title: "Smart Notifications",
                    description: "Stay updated with law changes"
                )
            }
            .padding(.horizontal)

            Spacer()

            Button(action: {
                currentPage = 1
            }) {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .padding()
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
    }
}

struct LocationPermissionView: View {
    @Binding var currentPage: Int
    @EnvironmentObject var locationManager: LocationManager

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Image(systemName: "location.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(.blue)

            VStack(spacing: 16) {
                Text("Enable Location Services")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text("We'll use your location to show you relevant laws and regulations for your current state")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }

            VStack(alignment: .leading, spacing: 16) {
                InfoPoint(text: "Automatic state detection as you travel")
                InfoPoint(text: "Location data stays on your device")
                InfoPoint(text: "Battery-efficient background monitoring")
            }
            .padding(.horizontal, 40)

            Spacer()

            Button(action: {
                Task {
                    await locationManager.requestPermission()
                    currentPage = 2
                }
            }) {
                Text("Enable Location")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)

            Button(action: {}) {
                Text("Skip for now")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom)
        }
        .padding()
    }
}

struct NotificationPermissionView: View {
    @Binding var currentPage: Int
    @EnvironmentObject var notificationManager: NotificationManager

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Image(systemName: "bell.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(.blue)

            VStack(spacing: 16) {
                Text("Stay Informed")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Get notified about important law changes and document deadlines")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }

            VStack(alignment: .leading, spacing: 16) {
                InfoPoint(text: "New state law alerts when you travel")
                InfoPoint(text: "Document deadline reminders")
                InfoPoint(text: "Daily legal updates digest")
            }
            .padding(.horizontal, 40)

            Spacer()

            Button(action: {
                Task {
                    await notificationManager.requestPermission()
                    currentPage = 3
                }
            }) {
                Text("Enable Notifications")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)

            Button(action: {}) {
                Text("Skip for now")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom)
        }
        .padding()
    }
}

struct InfoPoint: View {
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)

            Text(text)
                .font(.subheadline)

            Spacer()
        }
    }
}

struct ProfileSetupView: View {
    @Binding var hasCompletedOnboarding: Bool
    @EnvironmentObject var userProfileManager: UserProfileManager

    @State private var homeState = "California"
    @State private var frequentStates: Set<String> = []
    @State private var housingStatus = "Renter"
    @State private var hasDriversLicense = true
    @State private var employmentType = "Full-time"

    let states = ["California", "Texas", "New York", "Florida", "Illinois"]
    let housingOptions = ["Renter", "Owner", "Temporary"]
    let employmentOptions = ["Full-time", "Part-time", "Self-employed", "Unemployed", "Student"]

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                VStack(spacing: 16) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)

                    Text("Set Up Your Profile")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Help us personalize your experience")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)

                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Home State", systemImage: "house.fill")
                            .font(.headline)

                        Picker("Home State", selection: $homeState) {
                            ForEach(states, id: \.self) { state in
                                Text(state).tag(state)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Label("States You Visit", systemImage: "airplane")
                            .font(.headline)

                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(states.filter { $0 != homeState }, id: \.self) { state in
                                HStack {
                                    Button(action: {
                                        if frequentStates.contains(state) {
                                            frequentStates.remove(state)
                                        } else {
                                            frequentStates.insert(state)
                                        }
                                    }) {
                                        HStack {
                                            Image(systemName: frequentStates.contains(state) ? "checkmark.circle.fill" : "circle")
                                                .foregroundColor(frequentStates.contains(state) ? .blue : .gray)

                                            Text(state)
                                                .foregroundColor(.primary)

                                            Spacer()
                                        }
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Label("Housing Status", systemImage: "building.2.fill")
                            .font(.headline)

                        Picker("Housing Status", selection: $housingStatus) {
                            ForEach(housingOptions, id: \.self) { option in
                                Text(option).tag(option)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Label("Driver's License", systemImage: "car.fill")
                            .font(.headline)

                        Toggle("I have a driver's license", isOn: $hasDriversLicense)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Label("Employment Type", systemImage: "briefcase.fill")
                            .font(.headline)

                        Picker("Employment Type", selection: $employmentType) {
                            ForEach(employmentOptions, id: \.self) { option in
                                Text(option).tag(option)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal)

                Button(action: {
                    saveProfile()
                    hasCompletedOnboarding = true
                }) {
                    Text("Complete Setup")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
    }

    private func saveProfile() {
        userProfileManager.homeState = homeState
        userProfileManager.frequentStates = Array(frequentStates)
        userProfileManager.housingStatus = housingStatus
        userProfileManager.hasDriversLicense = hasDriversLicense
        userProfileManager.employmentType = employmentType
        userProfileManager.saveProfile()
    }
}
