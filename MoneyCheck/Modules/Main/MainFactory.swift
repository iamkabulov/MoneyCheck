//
//  AppFactory.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 03.09.2025.
//


import UIKit

final class MainFactory {

    // MARK: - Dependencies (singletons)
    static let shared = MainFactory()

    private init() { }

    // MARK: - Root
    func makeMainModule() -> UINavigationController {
        let navigationController = UINavigationController()
        let router = MainRouter(navigationController: navigationController)
        let viewModel = MainViewModel(financeUseCase: FinanceUseCaseImpl.shared, router: router)
        let vc = MainViewController(viewModel: viewModel)
        navigationController.setViewControllers([vc], animated: false)
        return navigationController
    }
}
