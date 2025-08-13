import Foundation
import Combine

protocol FinanceUseCase {
    func getWallets() -> AnyPublisher<[WalletModel], Error>
    func getWallet(by id: UUID) -> AnyPublisher<WalletModel, Error>
    func getCategories() -> AnyPublisher<[CategoryModel], Error>
    func getCategory(by id: UUID) -> AnyPublisher<CategoryModel, Error>
    func getIncomes() -> AnyPublisher<[IncomeModel], Error>
    func getIncome(by id: UUID) -> AnyPublisher<IncomeModel, Error>
    func getTransactions(by id: UUID) -> AnyPublisher<[TransactionModel], Error>
    func updateWallet(_ wallet: WalletModel) -> AnyPublisher<Void, Error>
    func updateCategory(_ category: CategoryModel) -> AnyPublisher<Void, Error>
    func updateIncome(_ income: IncomeModel) -> AnyPublisher<Void, Error>
    func addTransaction(_ transaction: TransactionModel) -> AnyPublisher<Void, Error>
    func updateTransaction(_ transaction: TransactionModel) -> AnyPublisher<Void, Error>
    func createIncome(name: String, icon: String, color: String) -> AnyPublisher<Void, Error>
    func createWallet(name: String, icon: String, color: String) -> AnyPublisher<Void, Error>
    func createCategory(name: String, icon: String, color: String) -> AnyPublisher<Void, Error>
}

final class FinanceUseCaseImpl: FinanceUseCase {
    private let walletRepository: WalletRepository
    private let categoryRepository: CategoryRepository
    private let incomeRepository: IncomeRepository
    private let transactionRepository: TransactionRepository
    
    init(
        walletRepository: WalletRepository,
        categoryRepository: CategoryRepository,
        incomeRepository: IncomeRepository,
        transactionRepository: TransactionRepository
    ) {
        self.walletRepository = walletRepository
        self.categoryRepository = categoryRepository
        self.incomeRepository = incomeRepository
        self.transactionRepository = transactionRepository
    }
    
    func getWallets() -> AnyPublisher<[WalletModel], Error> {
        return walletRepository.getWallets()
    }

    func getWallet(by id: UUID) -> AnyPublisher<WalletModel, Error> {
        return walletRepository.getWallet(by: id)
    }

    func getCategories() -> AnyPublisher<[CategoryModel], Error> {
        return categoryRepository.getCategories()
    }

    func getCategory(by id: UUID) -> AnyPublisher<CategoryModel, Error> {
        return categoryRepository.getCategory(by: id)
    }

    func getIncomes() -> AnyPublisher<[IncomeModel], Error> {
        return incomeRepository.getIncomes()
    }

    func getIncome(by id: UUID) -> AnyPublisher<IncomeModel, Error> {
        return incomeRepository.getIncome(by: id)
    }

    func getTransactions(by id: UUID) -> AnyPublisher<[TransactionModel], Error> {
        return transactionRepository.getTransactions(by: id)
    }
    
    func updateWallet(_ wallet: WalletModel) -> AnyPublisher<Void, Error> {
        return walletRepository.updateWallet(wallet)
    }
    
    func updateCategory(_ category: CategoryModel) -> AnyPublisher<Void, Error> {
        return categoryRepository.updateCategory(category)
    }
    
    func updateIncome(_ income: IncomeModel) -> AnyPublisher<Void, Error> {
        return incomeRepository.updateIncome(income)
    }
    
    func addTransaction(_ transaction: TransactionModel) -> AnyPublisher<Void, Error> {
        return transactionRepository.addTransaction(transaction)
    }
    
    func updateTransaction(_ transaction: TransactionModel) -> AnyPublisher<Void, Error> {
        return transactionRepository.updateTransaction(transaction)
    }
    
    func createIncome(name: String, icon: String, color: String) -> AnyPublisher<Void, Error> {
        let income = IncomeModel(
            id: UUID(),
            name: name,
            amount: 0,
            icon: icon,
            color: color,
            transactions: []
        )
        return incomeRepository.addIncome(income)
    }
    
    func createWallet(name: String, icon: String, color: String) -> AnyPublisher<Void, Error> {
        let wallet = WalletModel(
            id: UUID(),
            name: name,
            type: .card,
            balance: 0,
            icon: icon,
            color: color,
            transactions: []
        )
        return walletRepository.addWallet(wallet)
    }
    
    func createCategory(name: String, icon: String, color: String) -> AnyPublisher<Void, Error> {
        let category = CategoryModel(
            id: UUID(),
            name: name,
            type: .expense,
            amount: 0,
            icon: icon,
            color: color,
            transactions: []
        )
        return categoryRepository.addCategory(category)
    }
} 
