//
//  SelectPeriodFactory.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 03.09.2025.
//

import UIKit

final class SelectPeriodFactory {

    // MARK: - Dependencies (singletons)
    static let shared = SelectPeriodFactory()

    private init() { }

    // MARK: - Root
    func makeSelectPeriodViewModel(router: SelectPeriodRouter) -> SelectPeriodViewModel {
        let viewModel = SelectPeriodViewModel(financeUseCase: FinanceUseCaseImpl.shared, router: router)
        return viewModel
    }
}
