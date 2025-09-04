import Foundation
import Combine

protocol FinanceUseCase {
    func getWallets(period: PeriodType) -> AnyPublisher<[WalletModel], Error>
    func getWallet(by id: UUID) -> AnyPublisher<WalletModel, Error>
    func getCategories(period: PeriodType) -> AnyPublisher<[CategoryModel], Error>
    func getCategory(by id: UUID) -> AnyPublisher<CategoryModel, Error>
    func getIncomes(period: PeriodType) -> AnyPublisher<[IncomeModel], Error>
    func getIncome(by id: UUID) -> AnyPublisher<IncomeModel, Error>
    func getTransactions(by id: UUID, period: PeriodType) -> AnyPublisher<[TransactionModel], Error>
    func updateWallet(_ wallet: WalletModel) -> AnyPublisher<Void, Error>
    func updateCategory(_ category: CategoryModel) -> AnyPublisher<Void, Error>
    func updateIncome(_ income: IncomeModel) -> AnyPublisher<Void, Error>
    func addTransaction(_ transaction: TransactionModel) -> AnyPublisher<Void, Error>
    func updateTransaction(_ transaction: TransactionModel) -> AnyPublisher<Void, Error>
    func createIncome(name: String, icon: String, color: String) -> AnyPublisher<Void, Error>
    func createWallet(name: String, icon: String, color: String) -> AnyPublisher<Void, Error>
    func createCategory(name: String, icon: String, color: String) -> AnyPublisher<Void, Error>
    func deleteWallet(by id: UUID) -> AnyPublisher<Void, Error>
    func deleteIncome(by id: UUID) -> AnyPublisher<Void, Error>
    func deleteCategory(by id: UUID) -> AnyPublisher<Void, Error>
    func getPeriod() -> AnyPublisher<PeriodType, Error>
    func savePeriod(period: PeriodType) -> AnyPublisher<Void, Error>
    func deleteTransaction(by id: UUID) -> AnyPublisher<Void, Error>
}

final class FinanceUseCaseImpl: FinanceUseCase {

    static let shared = FinanceUseCaseImpl()

    private let walletRepository = CoreDataWalletRepository()
    private let categoryRepository = CoreDataCategoryRepository()
    private let incomeRepository = CoreDataIncomeRepository()
    private let transactionRepository = CoreDataTransactionRepository()
    private let periodRepository = CoreDataPeriodRepository()

    private init() { }

    deinit {
        print("Deinit FinanceUseCaseImpl")
    }

    func getWallets(period: PeriodType) -> AnyPublisher<[WalletModel], Error> {
        return walletRepository.getWallets(period: period)
    }

    func getWallet(by id: UUID) -> AnyPublisher<WalletModel, Error> {
        return walletRepository.getWallet(by: id)
    }

    func getCategories(period: PeriodType) -> AnyPublisher<[CategoryModel], Error> {
        return categoryRepository.getCategories(period: period)
    }

    func getCategory(by id: UUID) -> AnyPublisher<CategoryModel, Error> {
        return categoryRepository.getCategory(by: id)
    }

    func getIncomes(period: PeriodType) -> AnyPublisher<[IncomeModel], Error> {
        return incomeRepository.getIncomes(period: period)
    }

    func getIncome(by id: UUID) -> AnyPublisher<IncomeModel, Error> {
        return incomeRepository.getIncome(by: id)
    }

    func getTransactions(by id: UUID, period: PeriodType) -> AnyPublisher<[TransactionModel], Error> {
        return transactionRepository.getTransactions(by: id, period: period)
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
            type: .income,
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
            type: .wallet,
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
            type: .category,
            amount: 0,
            icon: icon,
            color: color,
            transactions: []
        )
        return categoryRepository.addCategory(category)
    }

    func deleteWallet(by id: UUID) -> AnyPublisher<Void, Error> {
        return walletRepository.deleteWallet(by: id)
    }

    func deleteIncome(by id: UUID) -> AnyPublisher<Void, Error> {
        return incomeRepository.deleteIncome(by: id)
    }

    func deleteCategory(by id: UUID) -> AnyPublisher<Void, Error> {
        return categoryRepository.deleteCategory(by: id)
    }

    func getPeriod() -> AnyPublisher<PeriodType, Error> {
        return periodRepository.getPeriod()
    }

    func savePeriod(period: PeriodType) -> AnyPublisher<Void, Error> {
        return periodRepository.savePeriod(period)
    }

    func deleteTransaction(by id: UUID) -> AnyPublisher<Void, Error> {
        return transactionRepository.deleteTransaction(by: id)
    }
}
