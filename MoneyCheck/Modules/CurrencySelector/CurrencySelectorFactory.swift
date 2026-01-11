//
//  CurrencySelectorFactory.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 08.01.2026.
//

import UIKit

final class CurrencySelectorFactory {
    static let shared = CurrencySelectorFactory()

    private init() { }

    // MARK: - Root
    func makeCurrencySelectorModule(_ nav: UINavigationController) -> UIViewController {
        let router = CurrencySelectorRouter(navigationController: nav)
        let currencyRepository: CoreDataSettingsRepositoryProtocol = CoreDataSettingsRepository()

        let useCase = ConfigurationsUseCase(
            currencyRepository: currencyRepository
        )
        let viewModel = CurrencySelectorViewModel(
            useCase: useCase,
            router: router,
            configurations: Configurations.shared
        )
        let vc = CurrencySelectorViewController(viewModel: viewModel)

        return vc
    }
}
