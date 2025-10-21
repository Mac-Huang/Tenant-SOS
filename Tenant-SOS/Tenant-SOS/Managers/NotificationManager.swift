import UserNotifications
import SwiftUI
import Combine

class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published var pendingNotifications: [UNNotificationRequest] = []

    private let notificationCenter = UNUserNotificationCenter.current()

    override init() {
        super.init()
        notificationCenter.delegate = self
        checkAuthorizationStatus()
    }

    @MainActor
    func requestPermission() async {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .badge, .sound])
            if granted {
                authorizationStatus = .authorized
                await MainActor.run {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                authorizationStatus = .denied
            }
        } catch {
            print("Failed to request notification permission: \(error)")
        }
    }

    func checkAuthorizationStatus() {
        notificationCenter.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.authorizationStatus = settings.authorizationStatus
            }
        }
    }

    func sendStateChangeNotification(newState: String) {
        let content = UNMutableNotificationContent()
        content.title = "Welcome to \(newState)!"
        content.body = "Tap to view important laws and regulations for \(newState)"
        content.sound = .default
        content.categoryIdentifier = "STATE_CHANGE"
        content.userInfo = ["state": newState]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "state-change-\(newState)",
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to add notification: \(error)")
            }
        }
    }

    func scheduleDocumentReminder(for document: String, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Document Reminder"
        content.body = "Your \(document) needs attention"
        content.sound = .default
        content.categoryIdentifier = "DOCUMENT_REMINDER"

        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: "document-\(document)-\(date.timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to schedule document reminder: \(error)")
            }
        }
    }

    func sendLawUpdate(category: String, state: String) {
        let content = UNMutableNotificationContent()
        content.title = "Law Update"
        content.body = "\(category) laws have been updated in \(state)"
        content.sound = .default
        content.categoryIdentifier = "LAW_UPDATE"
        content.userInfo = ["category": category, "state": state]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "law-update-\(category)-\(state)",
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to send law update: \(error)")
            }
        }
    }

    func configureDailyDigest(at hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Daily Legal Update"
        content.body = "Check today's legal updates and reminders"
        content.sound = .default
        content.categoryIdentifier = "DAILY_DIGEST"

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "daily-digest",
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to configure daily digest: \(error)")
            }
        }
    }

    func cancelNotification(withIdentifier identifier: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
    }

    func getPendingNotifications() {
        notificationCenter.getPendingNotificationRequests { [weak self] requests in
            DispatchQueue.main.async {
                self?.pendingNotifications = requests
            }
        }
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo

        switch response.notification.request.content.categoryIdentifier {
        case "STATE_CHANGE":
            if let state = userInfo["state"] as? String {
                NotificationCenter.default.post(
                    name: NSNotification.Name("OpenStateDetails"),
                    object: nil,
                    userInfo: ["state": state]
                )
            }
        case "DOCUMENT_REMINDER":
            NotificationCenter.default.post(
                name: NSNotification.Name("OpenDocuments"),
                object: nil
            )
        case "LAW_UPDATE":
            if let category = userInfo["category"] as? String,
               let state = userInfo["state"] as? String {
                NotificationCenter.default.post(
                    name: NSNotification.Name("OpenLawCategory"),
                    object: nil,
                    userInfo: ["category": category, "state": state]
                )
            }
        default:
            break
        }

        completionHandler()
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
}
