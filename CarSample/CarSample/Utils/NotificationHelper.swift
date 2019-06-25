import Foundation
import UserNotifications

public protocol UserNotification {
    var id: String { get }
    var title: String { get }
    var body: String { get }
}

public class NotificationHelper {
    
    public init() {}
    public func presentNotification(_ notification: UserNotification, timeInterval: TimeInterval) {
        
        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.body = notification.body
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: notification.id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
            if let error = error {
                print("Error when presenting notification \(error)")
            } else {
                print("presenting notification \(notification.id)")
            }
        })
    }
}
