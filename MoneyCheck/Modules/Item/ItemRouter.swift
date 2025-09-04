//
//  AddItemRouter.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 03.09.2025.
//
// MARK: - Protocols

import UIKit

protocol ItemRouterProtocol: AnyObject {
    func pop(animated: Bool)
    func showError(_ title: String?, message: String?)
}


final class ItemRouter: BaseRouter {
    deinit {
        print("deinit ItemRouter")
    }
}

extension ItemRouter: ItemRouterProtocol {
    func closeItemView() {
        self.pop(animated: true)
    }
}
