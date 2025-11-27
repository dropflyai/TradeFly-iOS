//
//  NotificationManager.swift
//  TradeFly AI
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }

    func sendLocalNotification(for signal: TradingSignal) {
        let content = UNMutableNotificationContent()
        content.title = "🔥 \(signal.quality.rawValue) Quality Signal"
        content.subtitle = "\(signal.ticker) - \(signal.signalType.displayName)"
        content.body = "Target: +\(Int(signal.targetPercentage))% • Tap to review"
        content.sound = .default
        content.badge = 1

        // Trigger immediately
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        let request = UNNotificationRequest(
            identifier: signal.id,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }

    func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0)
    }
}
