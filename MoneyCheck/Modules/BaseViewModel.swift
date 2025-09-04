//
//  BaseViewModel.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 03.09.2025.
//


import Foundation

class BaseViewModel<RouterType: Any> {
    let financeUseCase: FinanceUseCase
    var router: RouterType?

    init(financeUseCase: FinanceUseCase, router: RouterType) {
        self.financeUseCase = financeUseCase
        self.router = router
    }
}
