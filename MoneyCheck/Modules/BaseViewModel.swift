//
//  BaseViewModel.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 03.09.2025.
//


import Foundation

class BaseViewModel<RouterType: Any, UseCaseType: Any> {
    let useCase: UseCaseType
    let router: RouterType

    init(useCase: UseCaseType, router: RouterType) {
        self.useCase = useCase
        self.router = router
    }
}
