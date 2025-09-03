//
//  EditTransactionFactory.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 03.09.2025.
//

import UIKit

final class EditTransactionFactory {

    // MARK: - Dependencies (singletons)
    static let shared = EditTransactionFactory()


    private init() { }

    // MARK: - Root
    func makeEditTransactionViewModel(_ transaction: TransactionModel, router: EditTransactionRouter) -> EditTransactionViewModel {
        let viewModel = EditTransactionViewModel(
            transaction: transaction,
            financeUseCase: FinanceUseCaseImpl.shared,
            router: router
        )
        return viewModel
    }
}
