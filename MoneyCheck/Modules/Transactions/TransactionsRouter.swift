//
//  TransactionRouter.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 02.09.2025.
//

import UIKit
import PanModal

protocol TransactionsRouterProtocol: AnyObject {
    func showTransactionEditView(_ transaction: TransactionModel)
    func showEditItemView(id: UUID, type: ItemType)
    func pop(animated: Bool)
    func showError(_ title: String?, message: String?)
    func openSelectPeriod()
}

final class TransactionsRouter: BaseRouter {

    deinit {
        print("Deinit TransactionsRouter")
    }
}

// MARK: - TransactionsRouting
extension TransactionsRouter: TransactionsRouterProtocol {
    func showTransactionEditView(_ transaction: TransactionModel) {
        let vc = EditTransactionFactory().makeEditTransactionModule(transaction, navigationController: navigationController)
        vc.hidesBottomBarWhenPushed = true
        self.push(vc, animated: true)
    }

    func showEditItemView(id: UUID, type: ItemType) {
        let vc = EditItemFactory().makeEditItemModule(id: id, type: type, navigationController: navigationController)
        vc.hidesBottomBarWhenPushed = true
        self.push(vc, animated: true)
    }

    func openSelectPeriod() {
        let vc = SelectPeriodFactory().makeSelectPeriodModule(navigationController: navigationController)
        vc.hidesBottomBarWhenPushed = true
        self.presentPanModal(vc)
    }
}
