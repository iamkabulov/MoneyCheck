import Foundation
import Combine

protocol FinanceUseCase {
    func getWallets() -> AnyPublisher<[WalletModel], Error>
    func getCategories() -> AnyPublisher<[CategoryModel], Error>
    func getIncomes() -> AnyPublisher<[IncomeModel], Error>
    func updateWallet(_ wallet: WalletModel) -> AnyPublisher<Void, Error>
    func updateCategory(_ category: CategoryModel) -> AnyPublisher<Void, Error>
    func updateIncome(_ income: IncomeModel) -> AnyPublisher<Void, Error>
}

final class FinanceUseCaseImpl: FinanceUseCase {
    private let walletRepository: WalletRepository
    private let categoryRepository: CategoryRepository
    private let incomeRepository: IncomeRepository
    
    init(walletRepository: WalletRepository, categoryRepository: CategoryRepository, incomeRepository: IncomeRepository) {
        self.walletRepository = walletRepository
        self.categoryRepository = categoryRepository
        self.incomeRepository = incomeRepository
    }
    
    func getWallets() -> AnyPublisher<[WalletModel], Error> {
        return walletRepository.getWallets()
    }
    
    func getCategories() -> AnyPublisher<[CategoryModel], Error> {
        return categoryRepository.getCategories()
    }
    
    func getIncomes() -> AnyPublisher<[IncomeModel], Error> {
        return incomeRepository.getIncomes()
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
} 