//
//  ReminderFactory.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 10.01.2026.
//

import UIKit
import PanModal

final class ReminderFactory {
    static let shared = ReminderFactory()

    private init() { }

    // MARK: - Root
    func makeReminderModule(_ nav: UINavigationController) -> UIViewController & PanModalPresentable {
        let router = ReminderRouter(navigationController: nav)

        let useCase = ReminderService()
        let viewModel = ReminderViewModel(
            useCase: useCase,
            router: router
        )
        let vc = ReminderViewController(viewModel: viewModel)

        return vc
    }
}
