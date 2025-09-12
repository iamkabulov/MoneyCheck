//
//  EditTransactionFactory.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 03.09.2025.
//

import UIKit

final class EditTransactionFactory {

    init() { }

    // MARK: - Root
    func makeEditTransactionModule(_ transaction: TransactionModel, navigationController: UINavigationController) -> UIViewController {
        let router = EditTransactionRouter(navigationController: navigationController)
        let transactionRepository = CoreDataTransactionRepository()
        let useCase = TransactionsUseCase(transactionRepository: transactionRepository)
        let viewModel = EditTransactionViewModel(transaction: transaction,
                                                 useCase: useCase,
                                                 router: router)

        let vc = EditTransactionViewController(viewModel: viewModel)
        return vc
    }
}
