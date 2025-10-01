import SwiftUI
import Combine

@main
struct TenantSOSApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var locationManager = LocationManager()
    @StateObject private var dataController = DataController()
    @StateObject private var userProfileManager = UserProfileManager()
    @StateObject private var storeManager = StoreManager()
    @StateObject private var notificationManager = NotificationManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(locationManager)
                .environmentObject(dataController)
                .environmentObject(userProfileManager)
                .environmentObject(storeManager)
                .environmentObject(notificationManager)
        }
    }
}

// Simple app state management
class AppState: ObservableObject {
    @Published var currentState: String = "California"
    @Published var currentCity: String = "San Francisco"
    @Published var homeState: String = "CA"
    @Published var housingStatus: String = "renter"
    @Published var hasDriversLicense: Bool = true
    @Published var employmentType: String = "full-time"
    @Published var notificationPreference: String = "daily"
}