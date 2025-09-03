//
//  AddItemFactory.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 03.09.2025.
//

import UIKit

final class AddItemFactory {

    // MARK: - Dependencies (singletons)
    static let shared = AddItemFactory()

    private init() { }

    // MARK: - Root
    func makeAddItemViewModel(type: ItemType, router: AddItemRouter) -> AddItemViewModel {
        let viewModel = AddItemViewModel(type: type, financeUseCase: FinanceUseCaseImpl.shared, router: router)
        return viewModel
    }
}
