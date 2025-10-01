import CoreLocation
import Combine
import SwiftUI

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

    private let majorStates: [StateCoordinate] = [
        StateCoordinate(state: "California", code: "CA", latitude: 36.7783, longitude: -119.4179, radius: 400000),
        StateCoordinate(state: "Texas", code: "TX", latitude: 31.0000, longitude: -100.0000, radius: 500000),
        StateCoordinate(state: "New York", code: "NY", latitude: 43.0000, longitude: -75.0000, radius: 300000),
        StateCoordinate(state: "Florida", code: "FL", latitude: 27.6648, longitude: -81.5158, radius: 350000),
        StateCoordinate(state: "Illinois", code: "IL", latitude: 40.6331, longitude: -89.3985, radius: 300000)
    ]

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
        locationManager.allowsBackgroundLocationUpdates = false // Don't need background for now
        locationManager.showsBackgroundLocationIndicator = false

        authorizationStatus = locationManager.authorizationStatus
        // Don't start monitoring here - wait for explicit request
    }

    private func setupGeofencing() {
        for state in majorStates {
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
        case .authorizedWhenInUse, .authorizedAlways:
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

        if let state = majorStates.first(where: { $0.code == circularRegion.identifier }) {
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
    }

    func checkIfInState(_ stateCode: String) -> Bool {
        guard let currentLocation = currentLocation else { return false }

        if let state = majorStates.first(where: { $0.code == stateCode }) {
            let stateLocation = CLLocation(latitude: state.latitude, longitude: state.longitude)
            return currentLocation.distance(from: stateLocation) <= state.radius
        }

        return false
    }

    func getDistanceToState(_ stateCode: String) -> CLLocationDistance? {
        guard let currentLocation = currentLocation else { return nil }

        if let state = majorStates.first(where: { $0.code == stateCode }) {
            let stateLocation = CLLocation(latitude: state.latitude, longitude: state.longitude)
            return currentLocation.distance(from: stateLocation)
        }

        return nil
    }
}