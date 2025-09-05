//
//  CoreDataPeriodRepository.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 18.08.2025.
//

import Foundation
import Combine
import CoreData

protocol PeriodRepository {
    func savePeriod(_ value: PeriodType) -> AnyPublisher<Void, Error>
    func getPeriod() -> AnyPublisher<PeriodType, Error>
}


final class CoreDataPeriodRepository: PeriodRepository {

    private let coreDataManager = CoreDataManager.shared

    func getPeriod() -> AnyPublisher<PeriodType, any Error> {
        let result = coreDataManager.getPeriod()
        print("Core: \(result)")
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
