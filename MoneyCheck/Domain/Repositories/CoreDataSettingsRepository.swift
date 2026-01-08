//
//  CoreDataSettingsRepository.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 08.01.2026.
//

import Combine

protocol CoreDataSettingsRepositoryProtocol {
    func saveCurrency(_ value: Currency) -> AnyPublisher<Void, any Error>
    func getCurrency() -> AnyPublisher<Currency, any Error>
}


final class CoreDataSettingsRepository: CoreDataSettingsRepositoryProtocol {

    private let coreDataManager = CoreDataManager.shared

    func getCurrency() -> AnyPublisher<Currency, any Error> {
        let result = coreDataManager.getCurrency()
        return Just(result)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func saveCurrency(_ value: Currency) -> AnyPublisher<Void, any Error> {
        coreDataManager.saveCurrency(value)
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

}
