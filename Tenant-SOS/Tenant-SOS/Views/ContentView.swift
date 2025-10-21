import SwiftUI
import Combine

// ScrollToTop coordinator to handle tab reselection
class ScrollCoordinator: ObservableObject {
    @Published var scrollToTopTrigger: Int = 0

    func scrollToTop() {
        scrollToTopTrigger += 1
    }
}

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var showWelcomeHome = false
    @State private var justDismissedWelcome = false
    @State private var selectedTab = 0
    @State private var isReady = false
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataController: DataController
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var userProfileManager: UserProfileManager
    @StateObject private var scrollCoordinator = ScrollCoordinator()
    @Environment(\.scenePhase) var scenePhase

    var body: some View {
        ZStack {
            if isReady {
                Group {
                    if !hasCompletedOnboarding {
                        OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                            .environmentObject(locationManager)
                            .environmentObject(notificationManager)
                            .environmentObject(userProfileManager)
                    } else if showWelcomeHome {
                        WelcomeHomeView(hasSeenWelcome: $showWelcomeHome)
                            .environmentObject(userProfileManager)
                            .onChange(of: showWelcomeHome) { oldValue, newValue in
                                if !newValue {
                                    justDismissedWelcome = true
                                }
                            }
                    } else {
                        MainTabView(selectedTab: $selectedTab, scrollCoordinator: scrollCoordinator)
                            .environmentObject(scrollCoordinator)
                    }
                }
                .transition(.opacity)
            } else {
                // Loading screen
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Loading...")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .onAppear {

            // Show welcome home screen if onboarding completed
            if hasCompletedOnboarding {
                showWelcomeHome = true
            }

            // Start loading data
            dataController.loadDataAsync()

            // Delay to let managers initialize
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    isReady = true
                }
            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            // Show welcome screen when app becomes active from background
            if oldPhase == .background && newPhase == .active {
                if hasCompletedOnboarding && !justDismissedWelcome {
                    showWelcomeHome = true
                }
                // Refresh location when coming back to foreground
                locationManager.refreshLocation()
            } else if newPhase == .background {
                // Reset flag when going to background
                justDismissedWelcome = false
            } else if newPhase == .active {
                // Also refresh when app first becomes active
                locationManager.refreshLocation()
            }
        }
    }
}

struct MainTabView: View {
    @Binding var selectedTab: Int
    @ObservedObject var scrollCoordinator: ScrollCoordinator
    @State private var previousTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)

            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
                .tag(1)

            DocumentsView()
                .tabItem {
                    Image(systemName: "doc.text.fill")
                    Text("Documents")
                }
                .tag(2)

            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(3)
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            // Detect double-tap on same tab
            if oldValue == newValue {
                scrollCoordinator.scrollToTop()
            }
            previousTab = newValue
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}