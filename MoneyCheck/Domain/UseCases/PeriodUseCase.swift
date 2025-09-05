//
//  PeriodUseCase.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 06.09.2025.
//
import Foundation
import Combine

protocol PeriodUseCaseProtocol {
    func getPeriod() -> AnyPublisher<PeriodType, Error>
}

protocol PeriodSelectUseCaseProtocol {
    func savePeriod(period: PeriodType) -> AnyPublisher<Void, Error>
    func getPeriod() -> AnyPublisher<PeriodType, Error>
}

final class PeriodUseCase: PeriodUseCaseProtocol, PeriodSelectUseCaseProtocol {

    private let periodRepository = CoreDataPeriodRepository()

    init() {}

    deinit {
        print("--PeriodUseCase deinit")
    }

    func getPeriod() -> AnyPublisher<PeriodType, Error> {
        return periodRepository.getPeriod()
    }

    func savePeriod(period: PeriodType) -> AnyPublisher<Void, Error> {
        return periodRepository.savePeriod(period)
    }
}
