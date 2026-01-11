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

    // Output
    @Published private(set) var title: String = "Daily Reminder"

//    private let service: ReminderServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    private let configuration: Configurations

    init(
        useCase: ReminderServiceProtocol,
        router: ReminderRouterProtocol,
        configuration: Configurations
    ) {
        self.configuration = configuration
        super.init(useCase: useCase, router: router)
    }

    deinit {
        print("Deinited ReminderViewModel")
    }

    func saveReminder(_ time: Date) {
        updateReminder(isEnabled: true, time: time)
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

    func closeReminderView(didSave: Bool, time: Date) {
        if !didSave, let reminder = configuration.reminder {
            configuration.reminder = StoredReminder(
                isEnabled: reminder.isEnabled,
                time: reminder.time,
                title: Reminder.id,
                message: String(localized: "no_reminder")
            )
        } else {
            configuration.reminder = StoredReminder(
                isEnabled: didSave,
                time: time,
                title: Reminder.id,
                message: String(localized: "no_reminder")
            )
        }
        router.closeReminderView()
    }
}
