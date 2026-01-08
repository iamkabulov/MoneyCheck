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
        let walletRepository = CoreDataWalletRepository()
        let categoryRepository = CoreDataCategoryRepository()
        let incomeRepository = CoreDataIncomeRepository()
        let transactionRepository = CoreDataTransactionRepository()
        let periodRepository = CoreDataPeriodRepository()
        let currencyRepository = CoreDataSettingsRepository()
        let mainUseCase = MainUseCase(
            walletRepository: walletRepository,
            categoryRepository: categoryRepository,
            incomeRepository: incomeRepository,
            transactionRepository: transactionRepository,
            periodRepository: periodRepository,
            currencyRepository: currencyRepository
        )
        let router = MainRouter(navigationController: navigationController)
        let viewModel = MainViewModel(useCase: mainUseCase,
                                      router: router)
        let vc = MainViewController(viewModel: viewModel)
        navigationController.setViewControllers([vc], animated: false)
        return navigationController
    }
}
