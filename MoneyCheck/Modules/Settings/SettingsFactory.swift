//
//  SettingsFactory.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 07.01.2026.
//

import UIKit

final class SettingsFactory {
    static let shared = SettingsFactory()

    private init() { }

    // MARK: - Root
    func makeSettingsModule() -> UINavigationController {
        let navigationController = UINavigationController()
        let router = SettingsRouter(navigationController: navigationController)

        let useCase = SettingsUseCase()
        let permissionUseCase = NotificationPermissionUseCase()
        let viewModel = SettingsViewModel(
            useCase: useCase,
            router: router,
            configuration: Configurations.shared,
            permissionUseCase: permissionUseCase
        )
        let vc = SettingsViewController(viewModel: viewModel)

        navigationController.setViewControllers([vc], animated: true)
        return navigationController
    }
}
