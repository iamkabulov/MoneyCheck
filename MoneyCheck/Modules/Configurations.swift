//
//  Configurations.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 08.01.2026.
//

import Combine

final class Configurations {

    static let shared = Configurations(
        useCase: ConfigurationsUseCase(
            currencyRepository: CoreDataSettingsRepository()
        )
    )
    @Published var selectedCurrency: Currency
    @Published var reminder: StoredReminder?

    let useCase: CurrencySelectorUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()

    private init(
        useCase: CurrencySelectorUseCaseProtocol,
        defaultCurrency: Currency = .init(code: "USD", name: "USD", symbol: "$")
    ) {
        self.useCase = useCase
        self.selectedCurrency = defaultCurrency

        self.getSelectedCurrency()
    }

    func selectCurrency(_ currency: Currency) {
        self.selectedCurrency = currency
        useCase.saveSelectedCurrency(currency)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Error loading data Configurations selectCurrency request: \(error)")
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }

    func getSelectedCurrency() {
        useCase.getSelectedCurrency()
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Error loading data Configurations getSelectedCurrency request: \(error)")
                }
            } receiveValue: { currency in
                self.selectedCurrency = currency
            }
            .store(in: &cancellables)
    }
}
