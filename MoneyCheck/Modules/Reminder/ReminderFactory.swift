//
//  ReminderFactory.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 10.01.2026.
//

import UIKit

final class ReminderFactory {
    static let shared = ReminderFactory()

    private init() { }

    // MARK: - Root
    func makeReminderModule(_ nav: UINavigationController) -> UIViewController {
        let router = ReminderRouter(navigationController: nav)

        let useCase = ReminderService()
        let permissionUseCase = NotificationPermissionUseCase()
        let viewModel = ReminderViewModel(
            useCase: useCase,
            router: router,
            configuration: Configurations.shared,
            permissionUseCase: permissionUseCase
        )
        let vc = ReminderViewController(viewModel: viewModel)

        return vc
    }
}
