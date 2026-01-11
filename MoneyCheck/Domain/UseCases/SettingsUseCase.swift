//
//  SettingsUseCase.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 07.01.2026.
//

import UserNotifications
import Combine

protocol SettingsUseCaseProtocol {
    func settingsItem(completion: @escaping (SettingsModel) -> Void)
    func loadReminder(completion: @escaping (StoredReminder) -> Void)
    var dataDidChange: AnyPublisher<Void, Never> { get }
    func requestPermission()
    func scheduleDaily(reminder: Reminder)
    func removeReminder(id: String)
}

final class SettingsUseCase: SettingsUseCaseProtocol {
    private let dataChangeCenter = DataChangeCenter.shared
    var dataDidChange: AnyPublisher<Void, Never> {
        dataChangeCenter.dataDidChange
    }
    
    let settingsProvider: SettingsProvider

    init() {
        self.settingsProvider = SettingsProvider()
    }

    func settingsItem(completion: @escaping (SettingsModel) -> Void) {
        settingsProvider.settingsItem { settingsModel in
            completion(settingsModel)
        }
    }

    func loadReminder(completion: @escaping (StoredReminder) -> Void) {
        UNUserNotificationCenter.current()
            .getPendingNotificationRequests { requests in

                guard let request = requests.first(where: {
                    $0.identifier == Reminder.id
                }) else {
                    completion(
                        StoredReminder(
                            isEnabled: false,
                            time: nil,
                            title: nil,
                            message: nil
                        )
                    )
                    return
                }

                let trigger = request.trigger as? UNCalendarNotificationTrigger
                let components = trigger?.dateComponents

                let time = components.flatMap {
                    Calendar.current.date(from: $0)
                }

                completion(
                    StoredReminder(
                        isEnabled: true,
                        time: time,
                        title: request.content.title,
                        message: request.content.body
                    )
                )
            }
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
    }

    func removeReminder(id: String) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [id])
    }

    func requestPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }
}
