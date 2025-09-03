//
//  SelectPeriodRouter.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 03.09.2025.
//

import UIKit

protocol SelectPeriodRouterProtocol: AnyObject {
    func start()
    func openCustomPeriodView(vm: SelectPeriodViewModel)
    func pop(animated: Bool)
    func showError(_ title: String?, message: String?)
}


final class SelectPeriodRouter: BaseRouter {
    deinit {
        print("deinit SelectPeriodRouter")
    }

    func start() {
        let viewModel = SelectPeriodFactory.shared.makeSelectPeriodViewModel(router: self)
        let vc = SelectPeriodViewController(viewModel: viewModel)
        vc.hidesBottomBarWhenPushed = true
        self.push(vc, animated: true)
    }
}

extension SelectPeriodRouter: SelectPeriodRouterProtocol {
    func openCustomPeriodView(vm: SelectPeriodViewModel) {
        let vc = CustomPeriodViewController(viewModel: vm)

        self.push(vc, animated: true)
    }

    func closeCustomPeriodView() {
        self.pop(animated: true)
    }

    func closeSelectPeriod() {
        self.pop(animated: true)
    }
}
