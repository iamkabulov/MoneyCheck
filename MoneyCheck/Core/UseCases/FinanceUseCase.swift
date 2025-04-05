import Foundation
import Combine

protocol FinanceUseCase {
    func getWallets() -> AnyPublisher<[WalletModel], Error>
    func getCategories() -> AnyPublisher<[CategoryModel], Error>
    func transferMoney(from sourceWallet: WalletModel, to targetWallet: WalletModel, amount: Double) -> AnyPublisher<Void, Error>
    func addExpense(from wallet: WalletModel, to category: CategoryModel, amount: Double) -> AnyPublisher<Void, Error>
    func addIncome(to wallet: WalletModel, from category: CategoryModel, amount: Double) -> AnyPublisher<Void, Error>
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
    
    func transferMoney(from sourceWallet: WalletModel, to targetWallet: WalletModel, amount: Double) -> AnyPublisher<Void, Error> {
        guard sourceWallet.balance >= amount else {
            return Fail(error: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Недостаточно средств"]))
                .eraseToAnyPublisher()
        }
        
        var updatedSourceWallet = sourceWallet
        var updatedTargetWallet = targetWallet
        
        updatedSourceWallet.balance -= amount
        updatedTargetWallet.balance += amount
        
        return walletRepository.updateWallet(updatedSourceWallet)
            .flatMap { _ in
                self.walletRepository.updateWallet(updatedTargetWallet)
            }
            .eraseToAnyPublisher()
    }
    
    func addExpense(from wallet: WalletModel, to category: CategoryModel, amount: Double) -> AnyPublisher<Void, Error> {
        guard wallet.balance >= amount else {
            return Fail(error: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Недостаточно средств"]))
                .eraseToAnyPublisher()
        }
        
        var updatedWallet = wallet
        var updatedCategory = category
        
        updatedWallet.balance -= amount
        updatedCategory.amount += amount
        
        return walletRepository.updateWallet(updatedWallet)
            .flatMap { _ in
                self.categoryRepository.updateCategory(updatedCategory)
            }
            .eraseToAnyPublisher()
    }
    
    func addIncome(to wallet: WalletModel, from category: CategoryModel, amount: Double) -> AnyPublisher<Void, Error> {
        var updatedWallet = wallet
        var updatedCategory = category
        
        updatedWallet.balance += amount
        updatedCategory.amount += amount
        
        return walletRepository.updateWallet(updatedWallet)
            .flatMap { _ in
                self.categoryRepository.updateCategory(updatedCategory)
            }
            .eraseToAnyPublisher()
    }
} 