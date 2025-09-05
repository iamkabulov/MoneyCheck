import Foundation
import Combine

typealias MainUseCaseProtocol = TransactionsUseCaseProtocol & PeriodUseCaseProtocol & ItemUseCaseProtocol

final class MainUseCase: MainUseCaseProtocol {

    private let walletRepository = CoreDataWalletRepository()
    private let categoryRepository = CoreDataCategoryRepository()
    private let incomeRepository = CoreDataIncomeRepository()
    private let transactionRepository = CoreDataTransactionRepository()
    private let periodRepository = CoreDataPeriodRepository()

    init() {}

    deinit {
        print("---Deinit MainUseCase")
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

    
    func addTransaction(_ transaction: TransactionModel) -> AnyPublisher<Void, Error> {
        return transactionRepository.addTransaction(transaction)
    }

    func getPeriod() -> AnyPublisher<PeriodType, Error> {
        return periodRepository.getPeriod()
    }
}
