//
//  SettingsViewModel.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 07.01.2026.
//

import Combine
import Foundation
import UserNotifications
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
    private var isWaitingForSettingsReturn = false
    private var shouldOpenReminderViewAfterPermission = false

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
        self.setupForegroundObserver()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupForegroundObserver() {
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                self?.checkPermissionAfterReturnFromSettings()
            }
            .store(in: &cancellables)
    }
    
    private func checkPermissionAfterReturnFromSettings() {
        guard isWaitingForSettingsReturn else { return }
        isWaitingForSettingsReturn = false
        
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if settings.authorizationStatus != .authorized {
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
                } else {
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
                }
            }
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
            reminder = StoredReminder(
                isEnabled: isEnabled,
                time: time,
                title: current?.title,
                message: current?.message
            )
            
            if isEnabled {
                // Запрашиваем разрешение перед включением
                requestPermissionToReceiveNotifications { [weak self] granted in
                    guard let self = self else { return }
                    
                    if granted {
                        self.enableReminder(time)
                    } else {
                        // Первый отказ или отказ при уже .denied — возвращаем тоггл в off
                        let disabledReminder = StoredReminder(
                            isEnabled: false,
                            time: time,
                            title: current?.title,
                            message: current?.message
                        )
                        self.reminder = disabledReminder
                        self.configuration.reminder = disabledReminder
                        self.disableReminder()
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
                
                requestPermissionToReceiveNotifications { [weak self] granted in
                    guard let self = self else { return }
                    
                    if granted {
                        // Только после получения разрешения открываем ReminderView
                        self.router.openReminderSettings()
                    } else {
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

        useCase.scheduleDaily(reminder: reminder)
    }

    func requestPermissionToReceiveNotifications(completion: @escaping (Bool) -> Void) {
        // Сначала проверяем текущий статус
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                // Первый запрос - показываем системный диалог
                UNUserNotificationCenter.current()
                    .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                        DispatchQueue.main.async {
                            if granted {
                                completion(true)
                            } else {
                                // Первый отказ - просто возвращаем false, не показываем алерт
                                completion(false)
                            }
                        }
                    }
            case .denied:
                // Статус уже .denied - показываем алерт с переходом в настройки
                DispatchQueue.main.async {
                    self?.isWaitingForSettingsReturn = true
                    // Проверяем, нужно ли открыть ReminderView после получения разрешения
                    // Если времени нет или это вызов из тапа на ячейку - нужно открыть
                    if self?.reminder?.time == nil {
                        self?.shouldOpenReminderViewAfterPermission = true
                    }
                    self?.router.showSettingsAlert(
                        title: String(localized: "notification_permission_denied"),
                        message: String(localized: "notification_permission_message"),
                        onCancel: { [weak self] in
                            guard let self = self else { return }
                            self.isWaitingForSettingsReturn = false
                            self.shouldOpenReminderViewAfterPermission = false
                            // Отключаем reminder при нажатии Cancel
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
                            completion(false)
                        },
                        onSettings: { [weak self] in
                            // Флаги уже установлены, проверка произойдет при возврате из настроек
                        }
                    )
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

    private func checkPermissionAndOpenReminderView() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch settings.authorizationStatus {
                case .authorized, .provisional, .ephemeral:
                    // Разрешение есть - открываем ReminderView
                    self.router.openReminderSettings()
                case .notDetermined:
                    // Первый запрос - показываем системный диалог
                    UNUserNotificationCenter.current()
                        .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                            DispatchQueue.main.async {
                                if granted {
                                    self.router.openReminderSettings()
                                }
                                // Если отказали, ничего не делаем
                            }
                        }
                case .denied:
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
                @unknown default:
                    break
                }
            }
        }
    }
    
    func didTapOnSettingsOption(option: SettingsEnum) {
        switch option {
            case .currency:
                self.router.openCurrencySelector()
            case .reminder:
                // Проверяем разрешение перед открытием ReminderView
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
