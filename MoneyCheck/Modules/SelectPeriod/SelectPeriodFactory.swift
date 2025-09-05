//
//  SelectPeriodFactory.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 03.09.2025.
//

import UIKit

final class SelectPeriodFactory {

    init() { }

    // MARK: - Root
    func makeSelectPeriodModule(navigationController: UINavigationController) -> UIViewController {
        let router = SelectPeriodRouter(navigationController: navigationController)
        let viewModel = SelectPeriodViewModel(useCase: PeriodUseCase(), router: router)
        let vc = SelectPeriodViewController(viewModel: viewModel)
        return vc
    }
}
