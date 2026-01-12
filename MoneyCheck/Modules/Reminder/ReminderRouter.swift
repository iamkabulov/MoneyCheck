//
//  ReminderRouter.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 10.01.2026.
//

protocol ReminderRouterProtocol: RouterProtocol {
    func closeReminderView()
}


final class ReminderRouter: BaseRouter, ReminderRouterProtocol {

    func closeReminderView() {
        self.dismiss(animated: true)
    }
}
