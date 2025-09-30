import Foundation
import SwiftUI
import CoreData
import Combine

class UserProfileManager: ObservableObject {
    @Published var homeState: String = ""
    @Published var frequentStates: [String] = []
    @Published var housingStatus: String = "Renter"
    @Published var hasDriversLicense: Bool = true
    @Published var employmentType: String = "Full-time"
    @Published var notificationPreference: String = "immediate"

    private let userDefaults = UserDefaults.standard

    private enum Keys {
        static let homeState = "user.homeState"
        static let frequentStates = "user.frequentStates"
        static let housingStatus = "user.housingStatus"
        static let hasDriversLicense = "user.hasDriversLicense"
        static let employmentType = "user.employmentType"
        static let notificationPreference = "user.notificationPreference"
    }

    init() {
        loadProfile()
    }

    func loadProfile() {
        homeState = userDefaults.string(forKey: Keys.homeState) ?? ""
        frequentStates = userDefaults.stringArray(forKey: Keys.frequentStates) ?? []
        housingStatus = userDefaults.string(forKey: Keys.housingStatus) ?? "Renter"
        hasDriversLicense = userDefaults.bool(forKey: Keys.hasDriversLicense)
        employmentType = userDefaults.string(forKey: Keys.employmentType) ?? "Full-time"
        notificationPreference = userDefaults.string(forKey: Keys.notificationPreference) ?? "immediate"
    }

    func saveProfile() {
        userDefaults.set(homeState, forKey: Keys.homeState)
        userDefaults.set(frequentStates, forKey: Keys.frequentStates)
        userDefaults.set(housingStatus, forKey: Keys.housingStatus)
        userDefaults.set(hasDriversLicense, forKey: Keys.hasDriversLicense)
        userDefaults.set(employmentType, forKey: Keys.employmentType)
        userDefaults.set(notificationPreference, forKey: Keys.notificationPreference)
    }

    func updateHomeState(_ state: String) {
        homeState = state
        saveProfile()
    }

    func addFrequentState(_ state: String) {
        if !frequentStates.contains(state) && state != homeState {
            frequentStates.append(state)
            saveProfile()
        }
    }

    func removeFrequentState(_ state: String) {
        frequentStates.removeAll { $0 == state }
        saveProfile()
    }

    func updateNotificationPreference(_ preference: String) {
        notificationPreference = preference
        saveProfile()
    }

    func isRelevantCategory(_ category: String) -> Bool {
        switch category {
        case "Tenant Rights":
            return housingStatus == "Renter"
        case "Traffic Laws":
            return hasDriversLicense
        case "Employment":
            return employmentType != "Unemployed" && employmentType != "Student"
        default:
            return true
        }
    }

    func getRelevantStates() -> [String] {
        var states = frequentStates
        if !homeState.isEmpty && !states.contains(homeState) {
            states.insert(homeState, at: 0)
        }
        return states
    }
}