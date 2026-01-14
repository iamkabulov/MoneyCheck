//
//  SettingsRouter.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 07.01.2026.
//

protocol SettingsRouterProtocol: RouterProtocol {
    func openCurrencySelector()
    func openReminderSettings()
    func openContactUs()
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

    func openContactUs() {
        let vc = ContactUsFactory.shared.makeContactUsModule(self.navigationController)
        vc.hidesBottomBarWhenPushed = true
        self.presentPanModal(vc)
    }
}
