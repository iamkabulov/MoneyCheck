//
//  CurrencySelectorRouter.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 08.01.2026.
//

protocol CurrencySelectorRouterProtocol {
    func closeCurrencySelectorView()
}


final class CurrencySelectorRouter: BaseRouter, CurrencySelectorRouterProtocol {

    func closeCurrencySelectorView() {
        self.pop(animated: true)
    }
}
