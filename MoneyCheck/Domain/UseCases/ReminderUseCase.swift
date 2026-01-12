//
//  ReminderUseCase.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 10.01.2026.
//

import UserNotifications
import Combine

protocol ReminderServiceProtocol {
    func scheduleDaily(reminder: Reminder)
    func removeReminder(id: String)
}

final class ReminderService: ReminderServiceProtocol {

    private let dataChangeCenter = DataChangeCenter.shared
    var dataDidChange: AnyPublisher<Void, Never> {
        dataChangeCenter.dataDidChange
    }
    
    func scheduleDaily(reminder: Reminder) {
        guard reminder.isEnabled else { return }

        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.body = reminder.body
        content.sound = .default

        var components = DateComponents()
        components.hour = reminder.hour
        components.minute = reminder.minute

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: Reminder.id,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
        dataChangeCenter.notify()
    }

    func removeReminder(id: String) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [id])
    }
}
