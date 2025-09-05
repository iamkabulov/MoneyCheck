//
//  EditItemFactory.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 03.09.2025.
//

import UIKit

final class EditItemFactory {

    init() { }

    // MARK: - Root
    func makeEditItemModule(id: UUID, type: ItemType, navigationController: UINavigationController) -> UIViewController {
        let router = ItemRouter(navigationController: navigationController)
        let viewModel = EditItemViewModel(
            id: id,
            type: type,
            useCase: ItemUseCase(),
            router: router
        )

        let vc = ItemViewController(viewModel: viewModel)
        return vc
    }
}
