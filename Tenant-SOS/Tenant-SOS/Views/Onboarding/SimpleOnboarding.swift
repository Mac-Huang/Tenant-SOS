import SwiftUI

struct SimpleOnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @EnvironmentObject var userProfileManager: UserProfileManager

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            // Logo
            Image(systemName: "shield.checkered")
                .font(.system(size: 100))
                .foregroundColor(.blue)
                .padding(.bottom, 20)

            // Title
            VStack(spacing: 10) {
                Text("Welcome to Tenant SOS")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text("Your Personal Legal Assistant")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            // Features
            VStack(alignment: .leading, spacing: 15) {
                FeatureItem(icon: "location.fill",
                           text: "Location-based laws")
                FeatureItem(icon: "doc.text.fill",
                           text: "Legal document templates")
                FeatureItem(icon: "magnifyingglass",
                           text: "Search state laws")
                FeatureItem(icon: "person.fill",
                           text: "Personalized for you")
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 20)

            Spacer()

            // Buttons
            VStack(spacing: 15) {
                Button(action: {
                    print("🔵 DEBUG: Get Started button tapped at \(Date())")
                    // Set default values
                    userProfileManager.homeState = "CA"
                    userProfileManager.housingStatus = "renter"
                    print("🔵 DEBUG: Setting hasCompletedOnboarding to true")
                    withAnimation {
                        hasCompletedOnboarding = true
                    }
                }) {
                    Text("Get Started")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .cornerRadius(12)
                }

                Button(action: {
                    print("🟡 DEBUG: Skip button tapped at \(Date())")
                    hasCompletedOnboarding = true
                }) {
                    Text("Skip for now")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 50)
        }
        .padding()
        .onAppear {
            print("✅ DEBUG: SimpleOnboardingView appeared at \(Date())")
            print("✅ DEBUG: UserProfileManager home state: \(userProfileManager.homeState)")
        }
    }
}

struct FeatureItem: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 30)

            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)

            Spacer()
        }
    }
}
