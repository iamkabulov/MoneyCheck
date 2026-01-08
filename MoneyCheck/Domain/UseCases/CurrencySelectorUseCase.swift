//
//  CurrencySelectorUseCase.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 08.01.2026.
//

import Combine

protocol CurrencySelectorUseCaseProtocol {
    var dataDidChange: AnyPublisher<Void, Never> { get }
    func getSelectedCurrency() -> AnyPublisher<Currency, Error>
    func saveSelectedCurrency(_ currency: Currency) -> AnyPublisher<Void, Error>
}

final class CurrencySelectorUseCase: CurrencySelectorUseCaseProtocol {

    private let dataChangeCenter = DataChangeCenter.shared
    var dataDidChange: AnyPublisher<Void, Never> {
        dataChangeCenter.dataDidChange
    }
    private let currencyRepository: CoreDataSettingsRepositoryProtocol
    
    init(currencyRepository: CoreDataSettingsRepositoryProtocol) {
        self.currencyRepository = currencyRepository
    }

    func saveSelectedCurrency(_ currency: Currency) -> AnyPublisher<Void, Error> {
        return currencyRepository.saveCurrency(currency)
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.dataChangeCenter.notify()
            })
            .eraseToAnyPublisher()
    }


    func getSelectedCurrency() -> AnyPublisher<Currency, any Error> {
        return currencyRepository.getCurrency()
    }

}
