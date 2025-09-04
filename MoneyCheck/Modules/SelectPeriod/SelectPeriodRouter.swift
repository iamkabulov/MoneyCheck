//
//  SelectPeriodRouter.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 03.09.2025.
//

import UIKit

protocol SelectPeriodRouterProtocol: AnyObject {
    func openCustomPeriodView(vm: SelectPeriodViewModel)
    func pop(animated: Bool)
    func showError(_ title: String?, message: String?)
}


final class SelectPeriodRouter: BaseRouter {
    deinit {
        print("deinit SelectPeriodRouter")
    }
}

extension SelectPeriodRouter: SelectPeriodRouterProtocol {
    func openCustomPeriodView(vm: SelectPeriodViewModel) {
        let vc = CustomPeriodViewController(viewModel: vm)
        self.push(vc, animated: true)
    }

}
