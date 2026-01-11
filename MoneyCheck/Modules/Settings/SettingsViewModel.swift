//
//  SettingsViewModel.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 07.01.2026.
//

import Combine
import Foundation

public struct SettingsViewModelEntity {
    public let title: String
    public let options: [SettingsOptionSection]
    public let appVersion: String
    public let userId: String

    public init(from model: SettingsModel) {
        self.title = model.title
        self.options = model.options
        self.appVersion = "version: \(model.appVersion ?? "Not available")"
        self.userId = "userId: \(model.userId ?? "Not available")"
    }
}


final class SettingsViewModel: BaseViewModel<SettingsRouterProtocol, SettingsUseCaseProtocol> {
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Published properties
    @Published private(set) var settingsViewModelEntity: SettingsViewModelEntity?
    @Published private(set) var reminder: StoredReminder?
    private let configuration: Configurations

    var reminderSubtitle: String {
        guard let reminder else {
            return String(localized: "no_reminder")
        }

        if let time = reminder.time {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter.string(from: time)
        }

        return String(localized: "select_time")
    }

    init(
        useCase: SettingsUseCaseProtocol,
        router: SettingsRouter,
        configuration: Configurations
    ) {
        self.configuration = configuration
        self.reminder = self.configuration.reminder
        super.init(useCase: useCase, router: router)
        self.bindDataChanges()
    }

    private func bindDataChanges() {
        useCase.settingsItem { settings in
            self.settingsViewModelEntity = .init(from: settings)
        }

        useCase.dataDidChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.reminder = self?.configuration.reminder
            }
            .store(in: &cancellables)

        configuration.$reminder
            .receive(on: DispatchQueue.main)
            .sink { [weak self] reminder in
                self?.reminder = reminder
            }
            .store(in: &cancellables)
    }

    func setReminderEnabled(_ isEnabled: Bool) {
        let current = reminder

        if let time = current?.time {
            reminder = StoredReminder(
                isEnabled: isEnabled,
                time: time,
                title: current?.title,
                message: current?.message
            )
            enableReminder(time)
        } else {
            if isEnabled {
                return router.openReminderSettings()
            }
        }
    }

    func disableReminder() {
        useCase.removeReminder(id: Reminder.id)
    }

    func enableReminder(_ time: Date) {
        useCase.removeReminder(id: Reminder.id)

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

    func didTapOnSettingsOption(option: SettingsEnum) {
        switch option {
            case .currency:
                self.router.openCurrencySelector()
            case .reminder:
                self.router.openReminderSettings()
            default:
                break
        }
//                case .termsAndConditions:
//                    presenter.didTapTermsAndConditions()
//                case .privacy:
//                    presenter.didTapPrivacy()
//                case .icon:
//                    presenter.didTapIcon()
//                case .feedback:
//                    presenter.didTapFeedback()
//                case .contactUs:
//                    presenter.didTapContactUs()
//                case .appReviews:
//                    presenter.didTapAppReviews()
//                case .deleteAccount:
//                    presenter.didTapDelete()
//                case .signOut:
//                    presenter.didTapSignOut()
//                case .promoCode:
//                    presenter.didTapPromoCode()
//                case .buySubscription:
//                    presenter.didTapBuySubscription()
//                default:
//                    break
//                }
    }
}
