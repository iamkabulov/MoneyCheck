import Foundation
import Combine

protocol WalletRepository {
    func getWallets() -> AnyPublisher<[WalletModel], Error>
    func addWallet(_ wallet: WalletModel) -> AnyPublisher<Void, Error>
    func updateWallet(_ wallet: WalletModel) -> AnyPublisher<Void, Error>
    func deleteWallet(_ wallet: WalletModel) -> AnyPublisher<Void, Error>
}

protocol CategoryRepository {
    func getCategories() -> AnyPublisher<[CategoryModel], Error>
    func addCategory(_ category: CategoryModel) -> AnyPublisher<Void, Error>
    func updateCategory(_ category: CategoryModel) -> AnyPublisher<Void, Error>
    func deleteCategory(_ category: CategoryModel) -> AnyPublisher<Void, Error>
}