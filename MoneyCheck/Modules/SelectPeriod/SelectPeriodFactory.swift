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
        let periodRepository = CoreDataPeriodRepository()
        let useCase = PeriodUseCase(periodRepository: periodRepository)
        let viewModel = SelectPeriodViewModel(useCase: useCase, router: router)
        let vc = SelectPeriodViewController(viewModel: viewModel)
        return vc
    }
}
