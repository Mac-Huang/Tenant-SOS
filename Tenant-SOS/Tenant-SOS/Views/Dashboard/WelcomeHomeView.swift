import SwiftUI

struct WelcomeHomeView: View {
    @Binding var hasSeenWelcome: Bool
    @EnvironmentObject var userProfileManager: UserProfileManager

    var body: some View {
        ZStack {
            // Beautiful gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.4, blue: 0.9),
                    Color(red: 0.2, green: 0.6, blue: 1.0),
                    Color(red: 0.3, green: 0.8, blue: 0.9)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Content
            VStack(spacing: 30) {
                Spacer()

                // Icon
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 120, height: 120)

                    Image(systemName: "shield.lefthalf.filled.badge.checkmark")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                }

                // Text
                VStack(spacing: 16) {
                    Text("Welcome Back!")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)

                    if !userProfileManager.homeState.isEmpty {
                        Text("Protecting Your Rights in \(userProfileManager.homeState)")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                    } else {
                        Text("Your Legal Assistant is Ready")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                    }
                }

                Spacer()

                // Continue button
                Button(action: {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        hasSeenWelcome = false
                    }
                }) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(Color(red: 0.1, green: 0.4, blue: 0.9))
                        .frame(maxWidth: 250)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(25)
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                }
                .padding(.bottom, 60)
            }
            .padding()
        }
        .onAppear {
            print("🟢 WelcomeHomeView appeared")
        }
    }
}
