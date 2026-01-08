//
//  CoreDataPeriodRepository.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 18.08.2025.
//

import Foundation
import Combine
import CoreData

protocol PeriodRepositoryProtocol {
    func savePeriod(_ value: PeriodType) -> AnyPublisher<Void, Error>
    func getPeriod() -> AnyPublisher<PeriodType, Error>
}


final class CoreDataPeriodRepository: PeriodRepositoryProtocol {

    private let coreDataManager = CoreDataManager.shared

    func getPeriod() -> AnyPublisher<PeriodType, any Error> {
        let result = coreDataManager.getPeriod()
        return Just(result)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func savePeriod(_ value: PeriodType) -> AnyPublisher<Void, any Error> {
        coreDataManager.savePeriod(value)
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

}
