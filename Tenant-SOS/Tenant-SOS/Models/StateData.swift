import Foundation
import CoreLocation

// MARK: - State Data Model
struct StateInfo {
    let name: String
    let code: String
    let capital: String
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees
    let radius: CLLocationDistance // In meters
    let region: String // Northeast, Southeast, Midwest, Southwest, West
}

// MARK: - All 50 US States with Geographic Centers
struct StateDatabase {
    static let allStates: [StateInfo] = [
        // Northeast
        StateInfo(name: "Connecticut", code: "CT", capital: "Hartford", latitude: 41.6032, longitude: -73.0877, radius: 80000, region: "Northeast"),
        StateInfo(name: "Maine", code: "ME", capital: "Augusta", latitude: 45.2538, longitude: -69.4455, radius: 150000, region: "Northeast"),
        StateInfo(name: "Massachusetts", code: "MA", capital: "Boston", latitude: 42.4072, longitude: -71.3824, radius: 100000, region: "Northeast"),
        StateInfo(name: "New Hampshire", code: "NH", capital: "Concord", latitude: 43.1939, longitude: -71.5724, radius: 90000, region: "Northeast"),
        StateInfo(name: "New Jersey", code: "NJ", capital: "Trenton", latitude: 40.0583, longitude: -74.4057, radius: 100000, region: "Northeast"),
        StateInfo(name: "New York", code: "NY", capital: "Albany", latitude: 43.0000, longitude: -75.0000, radius: 250000, region: "Northeast"),
        StateInfo(name: "Pennsylvania", code: "PA", capital: "Harrisburg", latitude: 41.2033, longitude: -77.1945, radius: 200000, region: "Northeast"),
        StateInfo(name: "Rhode Island", code: "RI", capital: "Providence", latitude: 41.5801, longitude: -71.4774, radius: 40000, region: "Northeast"),
        StateInfo(name: "Vermont", code: "VT", capital: "Montpelier", latitude: 44.5588, longitude: -72.5778, radius: 80000, region: "Northeast"),

        // Southeast
        StateInfo(name: "Alabama", code: "AL", capital: "Montgomery", latitude: 32.3182, longitude: -86.9023, radius: 200000, region: "Southeast"),
        StateInfo(name: "Arkansas", code: "AR", capital: "Little Rock", latitude: 35.2010, longitude: -91.8318, radius: 180000, region: "Southeast"),
        StateInfo(name: "Delaware", code: "DE", capital: "Dover", latitude: 38.9108, longitude: -75.5277, radius: 50000, region: "Southeast"),
        StateInfo(name: "Florida", code: "FL", capital: "Tallahassee", latitude: 27.6648, longitude: -81.5158, radius: 350000, region: "Southeast"),
        StateInfo(name: "Georgia", code: "GA", capital: "Atlanta", latitude: 32.1574, longitude: -82.9071, radius: 230000, region: "Southeast"),
        StateInfo(name: "Kentucky", code: "KY", capital: "Frankfort", latitude: 37.8393, longitude: -84.2700, radius: 200000, region: "Southeast"),
        StateInfo(name: "Louisiana", code: "LA", capital: "Baton Rouge", latitude: 30.4515, longitude: -91.1871, radius: 200000, region: "Southeast"),
        StateInfo(name: "Maryland", code: "MD", capital: "Annapolis", latitude: 39.0458, longitude: -76.6413, radius: 120000, region: "Southeast"),
        StateInfo(name: "Mississippi", code: "MS", capital: "Jackson", latitude: 32.3547, longitude: -89.3985, radius: 200000, region: "Southeast"),
        StateInfo(name: "North Carolina", code: "NC", capital: "Raleigh", latitude: 35.7596, longitude: -79.0193, radius: 250000, region: "Southeast"),
        StateInfo(name: "South Carolina", code: "SC", capital: "Columbia", latitude: 33.8361, longitude: -81.1637, radius: 180000, region: "Southeast"),
        StateInfo(name: "Tennessee", code: "TN", capital: "Nashville", latitude: 35.5175, longitude: -86.5804, radius: 250000, region: "Southeast"),
        StateInfo(name: "Virginia", code: "VA", capital: "Richmond", latitude: 37.4316, longitude: -78.6569, radius: 220000, region: "Southeast"),
        StateInfo(name: "West Virginia", code: "WV", capital: "Charleston", latitude: 38.5976, longitude: -80.4549, radius: 150000, region: "Southeast"),

        // Midwest
        StateInfo(name: "Illinois", code: "IL", capital: "Springfield", latitude: 40.6331, longitude: -89.3985, radius: 250000, region: "Midwest"),
        StateInfo(name: "Indiana", code: "IN", capital: "Indianapolis", latitude: 40.2672, longitude: -86.1349, radius: 200000, region: "Midwest"),
        StateInfo(name: "Iowa", code: "IA", capital: "Des Moines", latitude: 41.8780, longitude: -93.0977, radius: 200000, region: "Midwest"),
        StateInfo(name: "Kansas", code: "KS", capital: "Topeka", latitude: 39.0119, longitude: -98.4842, radius: 250000, region: "Midwest"),
        StateInfo(name: "Michigan", code: "MI", capital: "Lansing", latitude: 44.3148, longitude: -85.6024, radius: 300000, region: "Midwest"),
        StateInfo(name: "Minnesota", code: "MN", capital: "St. Paul", latitude: 46.7296, longitude: -94.6859, radius: 300000, region: "Midwest"),
        StateInfo(name: "Missouri", code: "MO", capital: "Jefferson City", latitude: 37.9643, longitude: -91.8318, radius: 250000, region: "Midwest"),
        StateInfo(name: "Nebraska", code: "NE", capital: "Lincoln", latitude: 41.4925, longitude: -99.9018, radius: 250000, region: "Midwest"),
        StateInfo(name: "North Dakota", code: "ND", capital: "Bismarck", latitude: 47.5515, longitude: -101.0020, radius: 250000, region: "Midwest"),
        StateInfo(name: "Ohio", code: "OH", capital: "Columbus", latitude: 40.4173, longitude: -82.9071, radius: 220000, region: "Midwest"),
        StateInfo(name: "South Dakota", code: "SD", capital: "Pierre", latitude: 43.9695, longitude: -99.9018, radius: 250000, region: "Midwest"),
        StateInfo(name: "Wisconsin", code: "WI", capital: "Madison", latitude: 43.7844, longitude: -88.7879, radius: 230000, region: "Midwest"),

        // Southwest
        StateInfo(name: "Arizona", code: "AZ", capital: "Phoenix", latitude: 34.0489, longitude: -111.0937, radius: 300000, region: "Southwest"),
        StateInfo(name: "New Mexico", code: "NM", capital: "Santa Fe", latitude: 34.5199, longitude: -105.8701, radius: 300000, region: "Southwest"),
        StateInfo(name: "Oklahoma", code: "OK", capital: "Oklahoma City", latitude: 35.0078, longitude: -97.0929, radius: 250000, region: "Southwest"),
        StateInfo(name: "Texas", code: "TX", capital: "Austin", latitude: 31.0000, longitude: -100.0000, radius: 500000, region: "Southwest"),

        // West
        StateInfo(name: "Alaska", code: "AK", capital: "Juneau", latitude: 64.0685, longitude: -152.2782, radius: 800000, region: "West"),
        StateInfo(name: "California", code: "CA", capital: "Sacramento", latitude: 36.7783, longitude: -119.4179, radius: 400000, region: "West"),
        StateInfo(name: "Colorado", code: "CO", capital: "Denver", latitude: 39.5501, longitude: -105.7821, radius: 300000, region: "West"),
        StateInfo(name: "Hawaii", code: "HI", capital: "Honolulu", latitude: 19.8968, longitude: -155.5828, radius: 150000, region: "West"),
        StateInfo(name: "Idaho", code: "ID", capital: "Boise", latitude: 44.0682, longitude: -114.7420, radius: 280000, region: "West"),
        StateInfo(name: "Montana", code: "MT", capital: "Helena", latitude: 46.8797, longitude: -110.3626, radius: 350000, region: "West"),
        StateInfo(name: "Nevada", code: "NV", capital: "Carson City", latitude: 38.8026, longitude: -116.4194, radius: 300000, region: "West"),
        StateInfo(name: "Oregon", code: "OR", capital: "Salem", latitude: 43.8041, longitude: -120.5542, radius: 280000, region: "West"),
        StateInfo(name: "Utah", code: "UT", capital: "Salt Lake City", latitude: 39.3210, longitude: -111.0937, radius: 280000, region: "West"),
        StateInfo(name: "Washington", code: "WA", capital: "Olympia", latitude: 47.7511, longitude: -120.7401, radius: 250000, region: "West"),
        StateInfo(name: "Wyoming", code: "WY", capital: "Cheyenne", latitude: 43.0760, longitude: -107.2903, radius: 300000, region: "West")
    ]

    static func getState(byCode code: String) -> StateInfo? {
        return allStates.first { $0.code == code }
    }

    static func getState(byName name: String) -> StateInfo? {
        return allStates.first { $0.name.lowercased() == name.lowercased() }
    }

    static func getStates(byRegion region: String) -> [StateInfo] {
        return allStates.filter { $0.region == region }
    }
}