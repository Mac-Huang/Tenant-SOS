import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userProfileManager: UserProfileManager
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var selectedTab = 0

    var body: some View {
        Group {
            if !hasCompletedOnboarding {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
            } else {
                MainTabView(selectedTab: $selectedTab)
            }
        }
    }
}

struct MainTabView: View {
    @Binding var selectedTab: Int
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var notificationManager: NotificationManager

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(1)

            DocumentsView()
                .tabItem {
                    Label("Documents", systemImage: "doc.text.fill")
                }
                .tag(2)

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(3)
        }
        .accentColor(.blue)
        .onAppear {
            checkLocationUpdate()
        }
    }

    private func checkLocationUpdate() {
        if let newState = locationManager.currentState,
           newState != locationManager.previousState {
            notificationManager.sendStateChangeNotification(newState: newState)
            locationManager.previousState = newState
        }
    }
}