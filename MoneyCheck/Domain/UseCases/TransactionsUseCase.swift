//
//  EditTransactionUseCase.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 06.09.2025.
//

import Foundation
import Combine

protocol EditTransactionUseCaseProtocol {
    func updateTransaction(_ transaction: TransactionModel) -> AnyPublisher<Void, Error>
    func deleteTransaction(by id: UUID) -> AnyPublisher<Void, Error>
}

protocol TransactionsUseCaseProtocol {
    func addTransaction(_ transaction: TransactionModel) -> AnyPublisher<Void, Error>
    func getTransactions(by id: UUID, period: PeriodType) -> AnyPublisher<[TransactionModel], Error>
}

protocol TransactionsIntervalUserCaseProtocol {
    func getTransactionsForInterval(by id: UUID, start: Date, end: Date) -> AnyPublisher<[TransactionModel], Error>
    func getPeriod() -> AnyPublisher<PeriodType, Error>
}


final class TransactionsUseCase {

    private let transactionRepository: CoreDataTransactionRepository
    private let periodRepository: CoreDataPeriodRepository

    init(transactionRepository: CoreDataTransactionRepository, periodRepository: CoreDataPeriodRepository) {
        self.transactionRepository = transactionRepository
        self.periodRepository = periodRepository
    }

    deinit {
        print("--EditTransactionUseCase deinit")
    }
}

extension TransactionsUseCase: TransactionsUseCaseProtocol {
    func addTransaction(_ transaction: TransactionModel) -> AnyPublisher<Void, Error> {
        return transactionRepository.addTransaction(transaction)
    }

    func getTransactions(by id: UUID, period: PeriodType) -> AnyPublisher<[TransactionModel], Error> {
        return transactionRepository.getTransactions(by: id, period: period)
    }
}

extension TransactionsUseCase: EditTransactionUseCaseProtocol {
    func deleteTransaction(by id: UUID) -> AnyPublisher<Void, Error> {
         return transactionRepository.deleteTransaction(by: id)
    }

    func updateTransaction(_ transaction: TransactionModel) -> AnyPublisher<Void, Error> {
        return transactionRepository.updateTransaction(transaction)
    }
}

extension TransactionsUseCase: TransactionsIntervalUserCaseProtocol {
    func getTransactionsForInterval(by id: UUID, start: Date, end: Date) -> AnyPublisher<[TransactionModel], any Error> {
        return transactionRepository.getTransactionsForInterval(by: id, start: start, end: end)
    }

    func getPeriod() -> AnyPublisher<PeriodType, Error> {
        return periodRepository.getPeriod()
    }
}
