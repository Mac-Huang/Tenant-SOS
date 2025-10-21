import CoreLocation
import Combine
import SwiftUI
import UserNotifications
import MapKit

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
    private var currentGeocodingTask: Task<Void, Never>?

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

        print("🚀 LocationManager init - Authorization status: \(authorizationStatus.rawValue)")

        // Automatically start monitoring if we have permission
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            print("✅ Have permission, starting monitoring")
            startMonitoring()
            // Also request immediate location update
            locationManager.requestLocation()
        } else if authorizationStatus == .notDetermined {
            print("🔐 Requesting location permission")
            // Request permission if not determined
            locationManager.requestWhenInUseAuthorization()
        } else {
            print("❌ Location permission denied or restricted")
        }
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 50 // More frequent updates
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.allowsBackgroundLocationUpdates = true // Enable background location
        locationManager.showsBackgroundLocationIndicator = true // Show indicator when tracking in background

        authorizationStatus = locationManager.authorizationStatus
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
        print("🎯 startMonitoring called - Authorization: \(authorizationStatus.rawValue)")

        guard authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse else {
            print("⛔ Cannot start monitoring - no permission")
            return
        }

        isMonitoringLocation = true
        print("📍 Starting location updates...")

        // Use continuous location updates for better accuracy
        locationManager.startUpdatingLocation()

        // Only monitor significant changes if authorized for always
        if authorizationStatus == .authorizedAlways {
            print("📍 Starting significant location changes monitoring")
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

    func refreshLocation() {
        print("🔄 Manually refreshing location...")
        print("   Current authorization status: \(authorizationStatus.rawValue)")

        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            print("   ✓ Have permission, requesting location...")
            locationManager.requestLocation()
            // Also restart monitoring to ensure we're listening
            startMonitoring()

        case .notDetermined:
            print("   → Permission not determined, requesting...")
            locationManager.requestWhenInUseAuthorization()

        case .denied, .restricted:
            print("   ⚠️ Permission denied or restricted")
            print("   → User needs to enable location in Settings")

        @unknown default:
            print("   ⚠️ Unknown authorization status")
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            print("⚠️ No locations in update")
            return
        }

        print("📍 Got location update: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        print("   Accuracy: \(location.horizontalAccuracy)m, Timestamp: \(location.timestamp)")

        currentLocation = location
        reverseGeocode(location: location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error.localizedDescription)")
        // Don't set a default location - wait for actual location
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        print("🔐 Authorization changed to: \(authorizationStatus.rawValue)")

        switch authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            print("✅ Got permission, starting monitoring")
            startMonitoring()
            // Request immediate location update
            locationManager.requestLocation()
        default:
            print("⛔ No permission, stopping monitoring")
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
        // Cancel any previous geocoding task
        currentGeocodingTask?.cancel()

        print("📍 Reverse geocoding location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        print("   Timestamp: \(location.timestamp)")
        print("   Accuracy: \(location.horizontalAccuracy)m")

        currentGeocodingTask = Task {
            do {
                print("🔄 Starting geocoding request...")
                let placemark = try await fetchPlacemark(for: location)

                print("📦 Placemark details:")
                print("   - administrativeArea: \(placemark.administrativeArea ?? "nil")")
                print("   - locality: \(placemark.locality ?? "nil")")
                print("   - name: \(placemark.name ?? "nil")")
                print("   - country: \(placemark.country ?? "nil")")

                await MainActor.run {
                    // Get state abbreviation or full name
                    let state = placemark.administrativeArea ?? placemark.country ?? "Unknown"
                    let city = placemark.locality ?? placemark.name ?? "Unknown"

                    self.currentState = state
                    self.currentCity = city

                    print("✅ Location updated: \(city), \(state)")
                    print("   → currentState is now: \(self.currentState ?? "nil")")
                    print("   → currentCity is now: \(self.currentCity ?? "nil")")

                    if let newState = self.currentState,
                       newState != self.previousState {
                        self.handleStateChange(to: newState)
                    }
                }
            } catch {
                print("❌ Geocoding error: \(error)")
                print("   Location was: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                // Don't set fallback values - just wait for next location update
                await MainActor.run {
                    // Show detecting state instead of fake location
                    self.currentState = nil
                    self.currentCity = nil
                }
            }
        }
    }

    private func fetchPlacemark(for location: CLLocation) async throws -> CLPlacemark {
        if #available(iOS 18.0, *) {
            var request = MKReverseGeocodingRequest(location: location)
            request.preferredLocale = Locale.current
            let response = try await request.response()

            if let placemark = response.mapItems.first?.placemark {
                return placemark
            }

            throw GeocodingError.noPlacemark
        } else {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            if let placemark = placemarks.first {
                return placemark
            }
            throw GeocodingError.noPlacemark
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

private enum GeocodingError: Error {
    case noPlacemark
}
