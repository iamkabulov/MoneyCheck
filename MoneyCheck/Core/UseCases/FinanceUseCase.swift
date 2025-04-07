import Foundation
import Combine

protocol FinanceUseCase {
    func getWallets() -> AnyPublisher<[WalletModel], Error>
    func getCategories() -> AnyPublisher<[CategoryModel], Error>
    func updateWallet(_ wallet: WalletModel) -> AnyPublisher<Void, Error>
    func updateCategory(_ category: CategoryModel) -> AnyPublisher<Void, Error>
}

final class FinanceUseCaseImpl: FinanceUseCase {
    private let walletRepository: WalletRepository
    private let categoryRepository: CategoryRepository
    
    init(walletRepository: WalletRepository, categoryRepository: CategoryRepository) {
        self.walletRepository = walletRepository
        self.categoryRepository = categoryRepository
    }
    
    func getWallets() -> AnyPublisher<[WalletModel], Error> {
        return walletRepository.getWallets()
    }
    
    func getCategories() -> AnyPublisher<[CategoryModel], Error> {
        return categoryRepository.getCategories()
    }
    
    func updateWallet(_ wallet: WalletModel) -> AnyPublisher<Void, Error> {
        return walletRepository.updateWallet(wallet)
    }
    
    func updateCategory(_ category: CategoryModel) -> AnyPublisher<Void, Error> {
        return categoryRepository.updateCategory(category)
    }
} 