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
}
