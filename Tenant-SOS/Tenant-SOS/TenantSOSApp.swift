import SwiftUI
import Combine

@main
struct TenantSOSApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var locationManager = LocationManager()
    @StateObject private var dataController = DataController()
    @StateObject private var userProfileManager = UserProfileManager()
    @StateObject private var notificationManager = NotificationManager()
    @AppStorage("selectedTheme") private var selectedTheme = "system"

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(locationManager)
                .environmentObject(dataController)
                .environmentObject(userProfileManager)
                .environmentObject(notificationManager)
                .preferredColorScheme(getColorScheme())
        }
    }

    private func getColorScheme() -> ColorScheme? {
        switch selectedTheme {
        case "light":
            return .light
        case "dark":
            return .dark
        default:
            return nil // System default
        }
    }
}

// Simple app state management
class AppState: ObservableObject {
    @Published var currentState: String = ""
    @Published var currentCity: String = ""
    @Published var homeState: String = ""
    @Published var housingStatus: String = "renter"
    @Published var hasDriversLicense: Bool = true
    @Published var employmentType: String = "full-time"
    @Published var notificationPreference: String = "daily"
}