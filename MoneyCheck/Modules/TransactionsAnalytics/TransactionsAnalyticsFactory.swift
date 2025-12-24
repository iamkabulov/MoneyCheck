//
//  TransactionsAnalytics.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 22.12.2025.
//


import UIKit

final class TransactionsAnalyticsFactory {

    static let shared = TransactionsAnalyticsFactory()

    private init() { }

    // MARK: - Root
    func makeTransactionsAnalyticsModule() -> UIViewController {
        let router = TransactionsAnalyticsRouter(navigationController: UINavigationController())
        let walletRepository = CoreDataWalletRepository()
        let categoryRepository = CoreDataCategoryRepository()
        let incomeRepository = CoreDataIncomeRepository()
        let transactionRepository = CoreDataTransactionRepository()
        let periodRepository = CoreDataPeriodRepository()
        let useCase = TransactionsAnalyticsUseCase(
            walletRepository: walletRepository,
            categoryRepository: categoryRepository,
            incomeRepository: incomeRepository,
            transactionRepository: transactionRepository,
            periodRepository: periodRepository
        )
        let viewModel = TransactionsAnalyticsViewModel(useCase: useCase,
                                                       router: router)

        let vc = TransactionsAnalyticsViewController(viewModel: viewModel)
        return vc
    }
}
