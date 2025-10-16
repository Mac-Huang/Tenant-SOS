import CoreLocation
import Combine
import SwiftUI
import UserNotifications

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()

    @Published var currentLocation: CLLocation?
    @Published var currentState: String?
    @Published var currentCity: String?
    @Published var previousState: String?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isMonitoringLocation = false

    private let geocoder = CLGeocoder()
    private var stateRegions: [CLCircularRegion] = []
    private var cancellables = Set<AnyCancellable>()

    struct StateCoordinate {
        let state: String
        let code: String
        let latitude: CLLocationDegrees
        let longitude: CLLocationDegrees
        let radius: CLLocationDistance
    }

    // Use all 50 states from StateDatabase
    private var allStates: [StateInfo] {
        return StateDatabase.allStates
    }

    override init() {
        super.init()
        setupLocationManager()
        setupGeofencing()
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 100 // More frequent updates
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.allowsBackgroundLocationUpdates = true // Enable background location
        locationManager.showsBackgroundLocationIndicator = true // Show indicator when tracking in background

        authorizationStatus = locationManager.authorizationStatus
        // Don't start monitoring here - wait for explicit request
    }

    private func setupGeofencing() {
        // Monitor up to 20 nearest states (iOS limit for region monitoring)
        // In production, dynamically update based on user location
        let statesToMonitor = Array(allStates.prefix(20))

        for state in statesToMonitor {
            let region = CLCircularRegion(
                center: CLLocationCoordinate2D(latitude: state.latitude, longitude: state.longitude),
                radius: state.radius,
                identifier: state.code
            )
            region.notifyOnEntry = true
            region.notifyOnExit = true
            stateRegions.append(region)
        }
    }

    @MainActor
    func requestPermission() async {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization() // Start with when in use
        case .authorizedWhenInUse:
            // If we have "when in use", request "always" for background tracking
            locationManager.requestAlwaysAuthorization()
            startMonitoring()
        case .authorizedAlways:
            startMonitoring()
        case .denied, .restricted:
            print("Location access denied")
        @unknown default:
            break
        }
    }

    func startMonitoring() {
        guard authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse else {
            return
        }

        isMonitoringLocation = true
        locationManager.startUpdatingLocation()

        // Don't request location immediately - let it update naturally

        // Only monitor significant changes if authorized for always
        if authorizationStatus == .authorizedAlways {
            locationManager.startMonitoringSignificantLocationChanges()
            for region in stateRegions {
                locationManager.startMonitoring(for: region)
            }
        }
    }

    func stopMonitoring() {
        isMonitoringLocation = false
        locationManager.stopUpdatingLocation()
        locationManager.stopMonitoringSignificantLocationChanges()

        for region in stateRegions {
            locationManager.stopMonitoring(for: region)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location

        reverseGeocode(location: location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error.localizedDescription)")
        // Set default location for testing if needed
        if currentLocation == nil {
            // Default to San Francisco for testing
            let defaultLocation = CLLocation(latitude: 37.7749, longitude: -122.4194)
            currentLocation = defaultLocation
            reverseGeocode(location: defaultLocation)
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus

        switch authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            startMonitoring()
        default:
            stopMonitoring()
        }
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let circularRegion = region as? CLCircularRegion else { return }

        if let state = allStates.first(where: { $0.code == circularRegion.identifier }) {
            handleStateChange(to: state.code)
        }
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {

    }

    private func reverseGeocode(location: CLLocation) {
        // Cancel any previous geocoding
        geocoder.cancelGeocode()

        Task {
            do {
                let placemarks = try await geocoder.reverseGeocodeLocation(location)
                guard let placemark = placemarks.first else { return }

                await MainActor.run {
                    self.currentState = placemark.administrativeArea ?? "Unknown"
                    self.currentCity = placemark.locality ?? placemark.name ?? "Unknown"

                    print("Location updated: \(self.currentCity ?? "Unknown"), \(self.currentState ?? "Unknown")")

                    if let newState = self.currentState,
                       newState != self.previousState {
                        self.handleStateChange(to: newState)
                    }
                }
            } catch {
                print("Geocoding error: \(error)")
                // Set fallback values
                await MainActor.run {
                    if self.currentState == nil {
                        self.currentState = "California"
                        self.currentCity = "San Francisco"
                    }
                }
            }
        }
    }

    private func handleStateChange(to newState: String) {
        previousState = currentState
        currentState = newState

        NotificationCenter.default.post(
            name: NSNotification.Name("StateChanged"),
            object: nil,
            userInfo: ["newState": newState, "previousState": previousState ?? ""]
        )

        // Send local notification when entering a new state
        sendStateChangeNotification(newState: newState)
    }

    private func sendStateChangeNotification(newState: String) {
        let content = UNMutableNotificationContent()

        // Get state name from code
        let stateName = StateDatabase.getState(byCode: newState)?.name ?? newState

        content.title = "Welcome to \(stateName)!"

        // Get key differences if we have a previous state
        if let previousState = previousState {
            let criticalDifferences = StateLawsDatabase.getCriticalDifferences(from: previousState, to: newState, limit: 3)

            if !criticalDifferences.isEmpty {
                // Build notification body with key differences
                var bodyText = "⚠️ Key law differences:\n"
                for diff in criticalDifferences.prefix(2) {
                    bodyText += "\(diff.notificationText)\n"
                }
                bodyText += "\nTap for complete details"
                content.body = bodyText
            } else {
                content.body = "Laws are similar to \(previousState). Tap to review local regulations."
            }
        } else {
            content.body = "Tap to see important laws and regulations for \(stateName)."
        }

        content.sound = .default
        content.categoryIdentifier = "STATE_CHANGE"
        content.userInfo = [
            "state": newState,
            "previousState": previousState ?? "",
            "timestamp": Date().timeIntervalSince1970
        ]

        // Create trigger for immediate delivery
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        // Create request
        let request = UNNotificationRequest(
            identifier: "state-change-\(newState)-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )

        // Schedule notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("State change notification scheduled for \(newState)")
            }
        }
    }

    func checkIfInState(_ stateCode: String) -> Bool {
        guard let currentLocation = currentLocation else { return false }

        if let state = allStates.first(where: { $0.code == stateCode }) {
            let stateLocation = CLLocation(latitude: state.latitude, longitude: state.longitude)
            return currentLocation.distance(from: stateLocation) <= state.radius
        }

        return false
    }

    func getDistanceToState(_ stateCode: String) -> CLLocationDistance? {
        guard let currentLocation = currentLocation else { return nil }

        if let state = allStates.first(where: { $0.code == stateCode }) {
            let stateLocation = CLLocation(latitude: state.latitude, longitude: state.longitude)
            return currentLocation.distance(from: stateLocation)
        }

        return nil
    }
}