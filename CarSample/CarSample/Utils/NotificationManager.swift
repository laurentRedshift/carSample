import UIKit
import UserNotifications

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    
    static let shared = NotificationManager()
    
    private let application = UIApplication.shared

    override private init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    private var foregroundNotificationIdentifierPrefixes = [String]()

    func register(identifier: String) {
        foregroundNotificationIdentifierPrefixes.append(identifier)
    }
    
    func requestAuthorization() {
        var options: UNAuthorizationOptions
        options = [.badge, .sound, .alert]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { _, error in
            if let error = error {
                print("Failed to requestAuthorization: \(error)")
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        var identifierFound = false
        for foregroundNotificationIdentifier in foregroundNotificationIdentifierPrefixes {
            if notification.request.identifier.hasPrefix(foregroundNotificationIdentifier) {
                identifierFound = true
            }
        }
        if identifierFound {
            completionHandler([.badge, .sound, .alert])
        } else {
            completionHandler([])
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}
