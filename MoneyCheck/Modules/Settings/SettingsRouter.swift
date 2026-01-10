//
//  SettingsRouter.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 07.01.2026.
//

protocol SettingsRouterProtocol {
    func openCurrencySelector()
    func openReminderSettings()
}


final class SettingsRouter: BaseRouter, SettingsRouterProtocol {
    func openCurrencySelector() {
        let vc = CurrencySelectorFactory.shared.makeCurrencySelectorModule(self.navigationController)
        vc.hidesBottomBarWhenPushed = true
        self.push(vc, animated: true)
    }

    func openReminderSettings() {
        let vc = ReminderFactory.shared.makeReminderModule(self.navigationController)
        vc.hidesBottomBarWhenPushed = true
        self.presentPanModal(vc)
    }
}
