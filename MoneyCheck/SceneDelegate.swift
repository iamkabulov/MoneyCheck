//
//  SceneDelegate.swift
//  MoneyCheck
//
//  Created by Nursultan on 01.05.2026.
//


import UIKit
import CoreData
import UserNotifications

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        // убираем текст у кнопки назад
        let backButtonAppearance = UIBarButtonItemAppearance(style: .plain)
        
        backButtonAppearance.normal.titlePositionAdjustment = UIOffset(horizontal: -1000, vertical: 0)
        appearance.backButtonAppearance = backButtonAppearance
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        CoreDataManager.shared.initializeMockDataIfNeeded()
        window?.rootViewController = TabBarFactory().makeTabBarModule()
        window?.makeKeyAndVisible()
        
        // Восстанавливаем напоминание при старте приложения
        restoreReminderIfNeeded()
    }
    
    private func restoreReminderIfNeeded() {
        // Убеждаемся, что Configurations загружен
        let configuration = Configurations.shared
        
        // Небольшая задержка, чтобы Configurations успел загрузить данные
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            guard let reminder = configuration.reminder,
                  reminder.isEnabled,
                  let time = reminder.time else {
                return
            }
            
            // Проверяем разрешение и восстанавливаем напоминание
            let permissionUseCase = NotificationPermissionUseCase()
            permissionUseCase.checkCurrentStatus { result in
                guard case .granted = result else {
                    return
                }
                
                // Разрешение есть - восстанавливаем напоминание
                let components = Calendar.current.dateComponents([.hour, .minute], from: time)
                let reminderModel = Reminder(
                    title: String(localized: "reminder_title"),
                    body: String(localized: "reminder_body"),
                    hour: components.hour ?? 21,
                    minute: components.minute ?? 0,
                    isEnabled: true
                )
                
                let settingsUseCase = SettingsUseCase()
                settingsUseCase.removeReminder(id: Reminder.id)
                settingsUseCase.scheduleDaily(reminder: reminderModel)
            }
        }
    }
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MoneyCheck")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    // MARK: - Core Data Saving support
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let error = error as NSError
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
}
