//
//  CurrencySelectorUseCase.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 08.01.2026.
//

import Combine
import UserNotifications

protocol CurrencySelectorUseCaseProtocol {
    var dataDidChange: AnyPublisher<Void, Never> { get }
    func getSelectedCurrency() -> AnyPublisher<Currency, Error>
    func saveSelectedCurrency(_ currency: Currency) -> AnyPublisher<Void, Error>
}

final class ConfigurationsUseCase: CurrencySelectorUseCaseProtocol {

    private let dataChangeCenter = DataChangeCenter.shared
    var dataDidChange: AnyPublisher<Void, Never> {
        dataChangeCenter.dataDidChange
    }
    private let currencyRepository: CoreDataSettingsRepositoryProtocol
    
    init(currencyRepository: CoreDataSettingsRepositoryProtocol) {
        self.currencyRepository = currencyRepository
    }

    func saveSelectedCurrency(_ currency: Currency) -> AnyPublisher<Void, Error> {
        return currencyRepository.saveCurrency(currency)
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.dataChangeCenter.notify()
            })
            .eraseToAnyPublisher()
    }


    func getSelectedCurrency() -> AnyPublisher<Currency, any Error> {
        return currencyRepository.getCurrency()
    }
}

extension ConfigurationsUseCase: ReminderServiceProtocol {
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
