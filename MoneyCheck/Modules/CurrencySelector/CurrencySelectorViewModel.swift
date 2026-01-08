//
//  CurrencySelectorViewModel.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 08.01.2026.
//

import Combine
import UIKit

final class CurrencySelectorViewModel: BaseViewModel<CurrencySelectorRouterProtocol, CurrencySelectorUseCase> {
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Published properties
    @Published private(set) var selectedCurrency: Currency?

    let allCurrencies: [Currency] = [
        Currency(code: "USD", name: String(localized: "currency_usd"), symbol: "$"),
        Currency(code: "EUR", name: String(localized: "currency_eur"), symbol: "€"),
        Currency(code: "KZT", name: String(localized: "currency_kzt"), symbol: "₸"),
        Currency(code: "RUB", name: String(localized: "currency_rub"), symbol: "₽"),
        Currency(code: "GBP", name: String(localized: "currency_gbp"), symbol: "£"),
        Currency(code: "CNY", name: String(localized: "currency_cny"), symbol: "¥")
    ]

    var filteredCurrencies: [Currency] = []

    init(useCase: CurrencySelectorUseCase, router: CurrencySelectorRouter) {
        super.init(useCase: useCase, router: router)
        filteredCurrencies = allCurrencies
        getSelectedCurrency()
    }

    deinit {
        print("Deinited CurrencySelectorViewModel")
    }

    func filter(_ text: String) {
        guard !text.isEmpty else {
            filteredCurrencies = allCurrencies
            return
        }

        filteredCurrencies = allCurrencies.filter {
            $0.code.lowercased().contains(text.lowercased()) ||
            $0.name.lowercased().contains(text.lowercased())
        }
    }

    func selectCurrency(_ currency: Currency) {
        useCase.saveSelectedCurrency(currency)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Error loading data: \(error)")
                }
            } receiveValue: {
                self.router.closeCurrencySelectorView()
//                self.getSelectedCurrency()
            }
            .store(in: &cancellables)
    }

    func getSelectedCurrency() {
        useCase.getSelectedCurrency()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Error loading data: \(error)")
                }
            } receiveValue: { currency in
                self.selectedCurrency = currency
            }
            .store(in: &cancellables)
    }
}
