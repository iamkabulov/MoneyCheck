//
//  EditTransactionRouter.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 03.09.2025.
//

protocol EditTransactionRouterProtocol: AnyObject {
    func pop(animated: Bool)
    func showError(_ title: String?, message: String?)
}


final class EditTransactionRouter: BaseRouter {
    deinit {
        print("deinit EditTransactionRouter")
    }
}

extension EditTransactionRouter: EditTransactionRouterProtocol {
}
