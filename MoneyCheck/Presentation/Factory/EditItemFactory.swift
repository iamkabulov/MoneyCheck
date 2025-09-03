//
//  EditItemFactory.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 03.09.2025.
//

import UIKit

final class EditItemFactory {

    // MARK: - Dependencies (singletons)
    static let shared = EditItemFactory()

    private init() { }

    // MARK: - Root
    func makeEditItemViewModel(id: UUID, type: ItemType, router: AddItemRouter) -> EditItemViewModel {
        let viewModel = EditItemViewModel(
            id: id,
            type: type,
            financeUseCase: FinanceUseCaseImpl.shared,
            router: router
        )
        return viewModel
    }
}
