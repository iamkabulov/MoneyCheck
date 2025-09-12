import Foundation
import Combine

typealias MainUseCaseProtocol = TransactionsUseCaseProtocol & PeriodUseCaseProtocol & ItemUseCaseProtocol

final class MainUseCase: MainUseCaseProtocol {
    private let walletRepository: WalletRepositoryProtocol
    private let categoryRepository: CategoryRepositoryProtocol
    private let incomeRepository: IncomeRepositoryProtocol
    private let transactionRepository: TransactionRepositoryProtocol
    private let periodRepository: PeriodRepositoryProtocol

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
