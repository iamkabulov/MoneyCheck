//
//  PeriodRepository.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 18.08.2025.
//

import Combine


protocol PeriodRepository {
    func savePeriod(_ value: PeriodType) -> AnyPublisher<Void, Error>
    func getPeriod() -> AnyPublisher<PeriodType, Error>
}
