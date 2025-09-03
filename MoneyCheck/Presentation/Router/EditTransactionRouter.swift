//
//  EditTransactionRouter.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 03.09.2025.
//

protocol EditTransactionRouterProtocol: AnyObject {
    func start(_ vm: TransactionModel)
    func pop(animated: Bool)
    func showError(_ title: String?, message: String?)
}


final class EditTransactionRouter: BaseRouter {
    deinit {
        print("deinit EditTransactionRouter")
    }

    func start(_ vm: TransactionModel) {
        let viewModel = EditTransactionFactory.shared.makeEditTransactionViewModel(vm, router: self)
        let vc = EditTransactionViewController(viewModel: viewModel)
        vc.hidesBottomBarWhenPushed = true
        self.push(vc, animated: true)
    }

}

extension EditTransactionRouter: EditTransactionRouterProtocol {
}
