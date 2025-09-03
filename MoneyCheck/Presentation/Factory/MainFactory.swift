//
//  AppFactory.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 03.09.2025.
//


import UIKit

final class MainFactory {

    // MARK: - Dependencies (singletons)
    static let shared = MainFactory()

    private init() { }

    // MARK: - Root
    func makeMainViewModel(router: MainRouter) -> MainViewModel {
        let viewModel = MainViewModel(financeUseCase: FinanceUseCaseImpl.shared, router: router)
        return viewModel
    }
}
