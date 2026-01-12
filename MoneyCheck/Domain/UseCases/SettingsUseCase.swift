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
    var dataDidChange: AnyPublisher<Void, Never> { get }
    func requestPermission(completion: @escaping (Bool) -> Void)
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

    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                // Первый запрос - показываем системный диалог
                UNUserNotificationCenter.current()
                    .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                        DispatchQueue.main.async {
                            completion(granted)
                        }
                    }
            case .denied:
                // Пользователь отказал - нужно показать алерт для перехода в настройки
                DispatchQueue.main.async {
                    completion(false)
                }
            case .authorized, .provisional, .ephemeral:
                // Уже разрешено
                DispatchQueue.main.async {
                    completion(true)
                }
            @unknown default:
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }
}
