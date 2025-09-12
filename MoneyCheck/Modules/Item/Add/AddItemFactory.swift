//
//  AddItemFactory.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 03.09.2025.
//

import UIKit

final class AddItemFactory {

    init() { }

    // MARK: - Root
    func makeAddItemModule(type: ItemType, navigationController: UINavigationController) -> UIViewController {
        let router = ItemRouter(navigationController: navigationController)
        let incomeRepository = CoreDataIncomeRepository()
        let walletRepository = CoreDataWalletRepository()
        let categoryRepository = CoreDataCategoryRepository()

        let useCase = ItemUseCase(
            walletRepository: walletRepository,
            categoryRepository: categoryRepository,
            incomeRepository: incomeRepository
        )
        let viewModel = AddItemViewModel(type: type,
                                         useCase: useCase,
                                         router: router
        )
        let vc = ItemViewController(viewModel: viewModel)
        return vc
    }
}
