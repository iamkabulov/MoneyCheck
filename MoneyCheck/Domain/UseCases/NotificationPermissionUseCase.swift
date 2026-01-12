//
//  NotificationPermissionUseCase.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 12.01.2026.
//

import UserNotifications
import Foundation

enum NotificationPermissionResult {
    case granted
    case firstDenied       // Первый отказ из системного диалога
    case permanentlyDenied // Статус .denied (нужно вести в настройки)
}

protocol NotificationPermissionUseCaseProtocol {
    func checkAndRequestPermission(completion: @escaping (NotificationPermissionResult) -> Void)
    func checkCurrentStatus(completion: @escaping (NotificationPermissionResult) -> Void)
}

final class NotificationPermissionUseCase: NotificationPermissionUseCaseProtocol {

    func checkAndRequestPermission(completion: @escaping (NotificationPermissionResult) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                // Уже разрешено
                DispatchQueue.main.async {
                    completion(.granted)
                }

            case .notDetermined:
                // Первый запрос - показываем системный диалог
                UNUserNotificationCenter.current()
                    .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                        DispatchQueue.main.async {
                            completion(granted ? .granted : .firstDenied)
                        }
                    }

            case .denied:
                // Пользователь ранее отказал - нужно вести в настройки
                DispatchQueue.main.async {
                    completion(.permanentlyDenied)
                }

            @unknown default:
                DispatchQueue.main.async {
                    completion(.firstDenied)
                }
            }
        }
    }

    func checkCurrentStatus(completion: @escaping (NotificationPermissionResult) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                DispatchQueue.main.async {
                    completion(.granted)
                }
            case .denied:
                DispatchQueue.main.async {
                    completion(.permanentlyDenied)
                }
            case .notDetermined:
                DispatchQueue.main.async {
                    completion(.firstDenied)
                }
            @unknown default:
                DispatchQueue.main.async {
                    completion(.firstDenied)
                }
            }
        }
    }
}
