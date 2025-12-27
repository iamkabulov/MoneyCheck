//
//  TransactionsAnalyticsRouter.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 03.09.2025.
//

protocol TransactionsAnalyticsRouterProtocol: AnyObject {
    func showError(_ title: String?, message: String?)
    func openSelectPeriod()
}


final class TransactionsAnalyticsRouter: BaseRouter {
    deinit {
        print("deinit TransactionsAnalyticsRouter")
    }
}

extension TransactionsAnalyticsRouter: TransactionsAnalyticsRouterProtocol {
    func openSelectPeriod() {
        let vc = SelectPeriodFactory().makeSelectPeriodModule(navigationController: navigationController)
        vc.hidesBottomBarWhenPushed = true
        self.presentPanModal(vc)
    }
}
