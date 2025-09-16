import SwiftUI
import FirebaseCore
import CoreData

@main
struct TenantSOSApp: App {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var dataController = DataController()
    @StateObject private var userProfileManager = UserProfileManager()
    @StateObject private var notificationManager = NotificationManager()
    @StateObject private var storeManager = StoreManager()

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("selectedTheme") private var selectedTheme = "system"

    init() {
        FirebaseApp.configure()
        setupAppearance()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(locationManager)
                .environmentObject(dataController)
                .environmentObject(userProfileManager)
                .environmentObject(notificationManager)
                .environmentObject(storeManager)
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .preferredColorScheme(colorScheme)
                .onAppear {
                    requestPermissions()
                }
        }
    }

    private var colorScheme: ColorScheme? {
        switch selectedTheme {
        case "light":
            return .light
        case "dark":
            return .dark
        default:
            return nil
        }
    }

    private func setupAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance

        UITabBar.appearance().backgroundColor = UIColor.systemBackground
    }

    private func requestPermissions() {
        Task {
            await locationManager.requestPermission()
            await notificationManager.requestPermission()
        }
    }
}