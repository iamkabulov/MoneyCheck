//
//  ReminderViewModel.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 10.01.2026.
//


import UIKit
import Combine

final class ReminderViewModel: BaseViewModel<ReminderRouterProtocol, ReminderServiceProtocol> {

    // Input
    @Published var isEnabled: Bool = false
    @Published var time: Date = Date()

    // Output
    @Published private(set) var title: String = "Daily Reminder"

//    private let service: ReminderServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    override init(
        useCase: ReminderServiceProtocol,
        router: ReminderRouterProtocol
    ) {
        super.init(useCase: useCase, router: router)
        bind()
    }

    private func bind() {
        Publishers.CombineLatest($isEnabled, $time)
            .sink { [weak self] isEnabled, time in
                self?.updateReminder(isEnabled: isEnabled, time: time)
            }
            .store(in: &cancellables)
    }

    private func updateReminder(isEnabled: Bool, time: Date) {
        useCase.removeReminder(id: Reminder.id)

        guard isEnabled else { return }

        let components = Calendar.current.dateComponents([.hour, .minute], from: time)

        let reminder = Reminder(
            title: String(localized: "reminder_title"),
            body: String(localized: "reminder_body"),
            hour: components.hour ?? 21,
            minute: components.minute ?? 0,
            isEnabled: true
        )

        useCase.requestPermission()
        useCase.scheduleDaily(reminder: reminder)
    }
}
