import SwiftUI

struct ResetOnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Debug Menu")
                .font(.largeTitle)
                .padding()

            Text("Onboarding Status: \(hasCompletedOnboarding ? "Completed" : "Not Completed")")
                .font(.subheadline)

            Button(action: {
                hasCompletedOnboarding = false
                print("Reset onboarding - now showing onboarding view")
            }) {
                Text("Reset Onboarding")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
            }

            Button(action: {
                hasCompletedOnboarding = true
                print("Skip onboarding - now showing main app")
            }) {
                Text("Skip Onboarding")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
            }

            Spacer()
        }
        .padding()
    }
}