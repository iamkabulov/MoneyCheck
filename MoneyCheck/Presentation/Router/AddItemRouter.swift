//
//  AddItemRouter.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 03.09.2025.
//
// MARK: - Protocols

import UIKit

protocol AddItemRouterProtocol: AnyObject {
    func startAddNewItem(type: ItemType)
    func startEditItem(id: UUID, type: ItemType)
    func pop(animated: Bool)
    func showError(_ title: String?, message: String?)
}


final class AddItemRouter: BaseRouter {
    deinit {
        print("deinit AddItemRouter")
    }

    func startAddNewItem(type: ItemType) {
        let viewModel = AddItemFactory.shared.makeAddItemViewModel(type: type, router: self)
        let addVC = AddItemViewController(viewModel: viewModel)
        addVC.hidesBottomBarWhenPushed = true
        self.push(addVC, animated: true)
    }

    func startEditItem(id: UUID, type: ItemType) {
        let viewModel = EditItemFactory.shared.makeEditItemViewModel(id: id, type: type, router: self)
        let addVC = AddItemViewController(viewModel: viewModel)
        addVC.hidesBottomBarWhenPushed = true
        self.push(addVC, animated: true)
    }
}

extension AddItemRouter: AddItemRouterProtocol {
    func closeItemView() {
        self.pop(animated: true)
    }
}
