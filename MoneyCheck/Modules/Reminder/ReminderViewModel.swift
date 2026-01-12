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
    private let permissionUseCase: NotificationPermissionUseCaseProtocol

    init(
        useCase: ReminderServiceProtocol,
        router: ReminderRouterProtocol,
        configuration: Configurations,
        permissionUseCase: NotificationPermissionUseCaseProtocol
    ) {
        self.configuration = configuration
        self.permissionUseCase = permissionUseCase
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

        permissionUseCase.checkAndRequestPermission { [weak self] result in
            switch result {
                case .granted:
                    self?.useCase.scheduleDaily(reminder: reminder)
                case .firstDenied:
                    // Первый отказ - ничего не делаем
                    break
                case .permanentlyDenied:
                    self?.router.showSettingsAlert(
                        title: String(localized: "notification_permission_denied"),
                        message: String(localized: "notification_permission_message"),
                        onCancel: nil,
                        onSettings: nil
                    )
            }
        }
    }

    func closeReminderView(didSave: Bool, time: Date) {
        if !didSave, let reminder = configuration.reminder, let time = reminder.time {
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
