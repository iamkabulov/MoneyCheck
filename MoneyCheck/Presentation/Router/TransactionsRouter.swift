//
//  TransactionRouter.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 02.09.2025.
//

import UIKit

protocol TransactionsRouterProtocol: AnyObject {
    func showTransactionEditView(_ transaction: TransactionModel)
    func showEditItemView(id: UUID, type: ItemType)
    func start(for entity: TransactionItem, period: PeriodType)
    func pop(animated: Bool)
    func showError(_ title: String?, message: String?)
}

final class TransactionsRouter: BaseRouter {

    deinit {
        print("Deinit TransactionsRouter")
    }

    func start(for entity: TransactionItem, period: PeriodType) {
        let viewModel = TransactionsFactory.shared.makeTransactionsViewModel(for: entity, period: period, router: self)
        let vc = TransactionsViewController(viewModel: viewModel)
        vc.hidesBottomBarWhenPushed = true
        self.push(vc, animated: true)
    }
}

// MARK: - TransactionsRouting
extension TransactionsRouter: TransactionsRouterProtocol {
    func showTransactionEditView(_ transaction: TransactionModel) {
        let router = EditTransactionRouter(navigationController: navigationController)
        router.start(transaction)

    }

    func showEditItemView(id: UUID, type: ItemType) {
        let router = AddItemRouter(navigationController: navigationController)
        router.startEditItem(id: id, type: type)
    }
}
