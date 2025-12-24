//
//  TransactionsUseCaseProtocol.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 23.12.2025.
//


import Foundation
import Combine

protocol TransactionsAnalyticsUseCaseProtocol {
    var dataDidChange: AnyPublisher<Void, Never> { get }
    func getWallets(period: PeriodType) -> AnyPublisher<[WalletModel], Error>
    func getCategories(period: PeriodType) -> AnyPublisher<[CategoryModel], Error>
    func getIncomes(period: PeriodType) -> AnyPublisher<[IncomeModel], Error>
}

final class TransactionsAnalyticsUseCase: TransactionsAnalyticsUseCaseProtocol {

    var dataDidChange: AnyPublisher<Void, Never> {
        dataChangeCenter.dataDidChange
    }

    private let walletRepository: WalletRepositoryProtocol
    private let categoryRepository: CategoryRepositoryProtocol
    private let incomeRepository: IncomeRepositoryProtocol
    private let transactionRepository: TransactionRepositoryProtocol
    private let periodRepository: PeriodRepositoryProtocol
    private let dataChangeCenter = DataChangeCenter.shared

    init(walletRepository: WalletRepositoryProtocol,
         categoryRepository: CategoryRepositoryProtocol,
         incomeRepository: IncomeRepositoryProtocol,
         transactionRepository: TransactionRepositoryProtocol,
         periodRepository: PeriodRepositoryProtocol) {
        self.walletRepository = walletRepository
        self.categoryRepository = categoryRepository
        self.incomeRepository = incomeRepository
        self.transactionRepository = transactionRepository
        self.periodRepository = periodRepository
    }

    deinit {
        print("---Deinit TransactionsAnalyticsUseCase------")
    }

    func getWallets(period: PeriodType) -> AnyPublisher<[WalletModel], Error> {
        return walletRepository.getWallets(period: period)
    }

    func getCategories(period: PeriodType) -> AnyPublisher<[CategoryModel], Error> {
        return categoryRepository.getCategories(period: period)
    }

    func getIncomes(period: PeriodType) -> AnyPublisher<[IncomeModel], Error> {
        return incomeRepository.getIncomes(period: period)
    }

    func getTransactions(by id: UUID, period: PeriodType) -> AnyPublisher<[TransactionModel], Error> {
        return transactionRepository.getTransactions(by: id, period: period)
    }

    func getPeriod() -> AnyPublisher<PeriodType, Error> {
        return periodRepository.getPeriod()
    }
}
