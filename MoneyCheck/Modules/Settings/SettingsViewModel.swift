//
//  SettingsViewModel.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 07.01.2026.
//

import Combine
import Foundation
import UIKit

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
    private let permissionUseCase: NotificationPermissionUseCaseProtocol
    private var isWaitingForSettingsReturn = false
    private var shouldOpenReminderViewAfterPermission = false

    var reminderSubtitle: String {
        if let time = reminder?.time {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter.string(from: time)
        }

        return String(localized: "no_reminder")
    }

    init(
        useCase: SettingsUseCaseProtocol,
        router: SettingsRouter,
        configuration: Configurations,
        permissionUseCase: NotificationPermissionUseCaseProtocol
    ) {
        self.configuration = configuration
        self.reminder = self.configuration.reminder
        self.permissionUseCase = permissionUseCase
        super.init(useCase: useCase, router: router)
        self.bindDataChanges()
        self.setupForegroundObserver()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupForegroundObserver() {
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                self?.handleAppWillEnterForeground()
            }
            .store(in: &cancellables)
    }
    
    private func handleAppWillEnterForeground() {
        if isWaitingForSettingsReturn {
            // Проверяем разрешение после возврата из настроек
            checkPermissionAfterReturnFromSettings()
        } else {
            // Обычный возврат в приложение - восстанавливаем напоминание если нужно
            restoreReminderIfNeeded()
        }
    }
    
    private func checkPermissionAfterReturnFromSettings() {
        guard isWaitingForSettingsReturn else { return }
        isWaitingForSettingsReturn = false
        
        permissionUseCase.checkCurrentStatus { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .granted:
                // Разрешение дано
                if self.shouldOpenReminderViewAfterPermission {
                    // Нужно открыть ReminderView после получения разрешения (тап на ячейку или включение тоггла без времени)
                    self.shouldOpenReminderViewAfterPermission = false
                    self.router.openReminderSettings()
                } else {
                    // Проверяем состояние reminder
                    if let time = self.reminder?.time, self.reminder?.isEnabled == true {
                        // Время установлено - включаем reminder
                        self.enableReminder(time)
                    } else if self.reminder?.time == nil && self.reminder?.isEnabled == true {
                        // Времени нет, но тоггл включен - открываем ReminderView
                        self.router.openReminderSettings()
                    }
                }
            case .firstDenied, .permanentlyDenied:
                // Разрешение все еще не дано - переводим тоггл в off
                let currentReminder = self.reminder
                let disabledReminder = StoredReminder(
                    isEnabled: false,
                    time: currentReminder?.time,
                    title: currentReminder?.title,
                    message: currentReminder?.message
                )
                self.reminder = disabledReminder
                self.configuration.reminder = disabledReminder
                self.disableReminder()
                self.shouldOpenReminderViewAfterPermission = false
            }
        }
    }
    
    private func restoreReminderIfNeeded() {
        guard let reminder = reminder,
              reminder.isEnabled,
              let time = reminder.time else {
            return
        }
        
        // Проверяем разрешение и восстанавливаем напоминание
        permissionUseCase.checkCurrentStatus { [weak self] result in
            guard let self = self else { return }
            
            guard case .granted = result else {
                return
            }
            
            // Разрешение есть - восстанавливаем напоминание
            self.enableReminder(time)
        }
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
            // Если время уже установлено, обновляем состояние и запрашиваем разрешение
            configuration.reminder = StoredReminder(
                isEnabled: isEnabled,
                time: time,
                title: current?.title,
                message: current?.message
            )
            
            if isEnabled {
                // Запрашиваем разрешение перед включением
                permissionUseCase.checkAndRequestPermission { [weak self] result in
                    guard let self = self else { return }
                    
                    switch result {
                    case .granted:
                        self.enableReminder(time)
                    case .firstDenied:
                        // Первый отказ - возвращаем тоггл в off
                        let disabledReminder = StoredReminder(
                            isEnabled: false,
                            time: time,
                            title: current?.title,
                            message: current?.message
                        )
                        self.reminder = disabledReminder
                        self.configuration.reminder = disabledReminder
                        self.disableReminder()
                    case .permanentlyDenied:
                        // Статус .denied - показываем алерт с переходом в настройки
                        self.isWaitingForSettingsReturn = true
                        self.router.showSettingsAlert(
                            title: String(localized: "notification_permission_denied"),
                            message: String(localized: "notification_permission_message"),
                            onCancel: { [weak self] in
                                guard let self = self else { return }
                                self.isWaitingForSettingsReturn = false
                                let disabledReminder = StoredReminder(
                                    isEnabled: false,
                                    time: time,
                                    title: current?.title,
                                    message: current?.message
                                )
                                self.reminder = disabledReminder
                                self.configuration.reminder = disabledReminder
                                self.disableReminder()
                            },
                            onSettings: {
                                // Флаг уже установлен, проверка произойдет при возврате из настроек
                            }
                        )
                    }
                }
            } else {
                disableReminder()
            }
        } else {
            // Если времени нет и пытаемся включить - сначала запрашиваем разрешение
            if isEnabled {
                // Обновляем состояние перед запросом разрешения
                reminder = StoredReminder(
                    isEnabled: true,
                    time: nil,
                    title: current?.title,
                    message: current?.message
                )
                configuration.reminder = reminder
                
                permissionUseCase.checkAndRequestPermission { [weak self] result in
                    guard let self = self else { return }
                    
                    switch result {
                    case .granted:
                        // Только после получения разрешения открываем ReminderView
                        self.router.openReminderSettings()
                    case .firstDenied:
                        // Первый отказ при отсутствии времени — возвращаем тоггл в off
                        let disabledReminder = StoredReminder(
                            isEnabled: false,
                            time: nil,
                            title: self.reminder?.title,
                            message: self.reminder?.message
                        )
                        self.reminder = disabledReminder
                        self.configuration.reminder = disabledReminder
                        self.disableReminder()
                    case .permanentlyDenied:
                        // Статус .denied - показываем алерт с переходом в настройки
                        self.isWaitingForSettingsReturn = true
                        self.shouldOpenReminderViewAfterPermission = true
                        self.router.showSettingsAlert(
                            title: String(localized: "notification_permission_denied"),
                            message: String(localized: "notification_permission_message"),
                            onCancel: { [weak self] in
                                guard let self = self else { return }
                                self.isWaitingForSettingsReturn = false
                                self.shouldOpenReminderViewAfterPermission = false
                                let disabledReminder = StoredReminder(
                                    isEnabled: false,
                                    time: nil,
                                    title: self.reminder?.title,
                                    message: self.reminder?.message
                                )
                                self.reminder = disabledReminder
                                self.configuration.reminder = disabledReminder
                                self.disableReminder()
                            },
                            onSettings: {
                                // Флаги уже установлены, проверка произойдет при возврате из настроек
                            }
                        )
                    }
                }
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
        configuration.reminder = .init(
            isEnabled: true,
            time: time,
            title: String(localized: "reminder_title"),
            message: String(localized: "reminder_body")
        )
        useCase.scheduleDaily(reminder: reminder)
    }

    private func checkPermissionAndOpenReminderView() {
        permissionUseCase.checkAndRequestPermission { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .granted:
                // Разрешение есть - открываем ReminderView
                self.router.openReminderSettings()
            case .firstDenied:
                // Первый отказ - ничего не делаем
                break
            case .permanentlyDenied:
                // Разрешение отклонено - показываем алерт
                self.isWaitingForSettingsReturn = true
                self.shouldOpenReminderViewAfterPermission = true
                self.router.showSettingsAlert(
                    title: String(localized: "notification_permission_denied"),
                    message: String(localized: "notification_permission_message"),
                    onCancel: { [weak self] in
                        self?.isWaitingForSettingsReturn = false
                        self?.shouldOpenReminderViewAfterPermission = false
                    },
                    onSettings: {
                        // Флаги уже установлены, проверка произойдет при возврате из настроек
                    }
                )
            }
        }
    }
    
    func didTapOnSettingsOption(option: SettingsEnum) {
        switch option {
            case .currency:
                self.router.openCurrencySelector()
            case .reminder:
                checkPermissionAndOpenReminderView()
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
