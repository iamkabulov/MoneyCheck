//
//  SelectPeriodRouter.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 03.09.2025.
//

import UIKit

protocol SelectPeriodRouterProtocol: AnyObject {
    func openCustomPeriodView(from: UIViewController, vm: SelectPeriodViewModel)
    func pop(animated: Bool)
    func dismiss(animated: Bool)
    func showError(_ title: String?, message: String?)
}


final class SelectPeriodRouter: BaseRouter {
    deinit {
        print("deinit SelectPeriodRouter")
    }
}

extension SelectPeriodRouter: SelectPeriodRouterProtocol {
    func openCustomPeriodView(from: UIViewController, vm: SelectPeriodViewModel) {
        let vc = CustomPeriodViewController(viewModel: vm)
        from.present(vc, animated: true)
    }
}
