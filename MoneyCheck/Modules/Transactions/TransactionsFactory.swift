//
//  TransactionsFactory.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 03.09.2025.
//

import UIKit

final class TransactionsFactory {

    init() { }

    // MARK: - Root
    func makeTransactionsModule(for entity: TransactionItem, period: PeriodType, navigationController: UINavigationController) -> UIViewController {
        let router = TransactionsRouter(navigationController: navigationController)
        let transactionRepository = CoreDataTransactionRepository()
        let useCase = TransactionsUseCase(transactionRepository: transactionRepository)
        let viewModel = TransactionsViewModel(useCase: useCase,
                                              itemId: entity.id,
                                              itemType: entity.type,
                                              router: router,
                                              period: period)
        let vc = TransactionsViewController(viewModel: viewModel)
        return vc
    }
}
