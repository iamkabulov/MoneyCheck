import Foundation
import Combine
import CoreData

final class CoreDataWalletRepository: WalletRepository {
    private let coreDataManager = CoreDataManager.shared
    
    func getWallets() -> AnyPublisher<[WalletModel], Error> {
        let wallets = coreDataManager.fetchWallets()
        let walletModels = wallets.map { wallet in
            WalletModel(
                id: wallet.id ?? UUID(),
                name: wallet.name ?? "",
                type: WalletType(rawValue: wallet.type ?? "") ?? .cash,
                balance: wallet.balance,
                icon: wallet.icon ?? "",
                color: wallet.color ?? ""
            )
        }
        return Just(walletModels)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func addWallet(_ wallet: WalletModel) -> AnyPublisher<Void, Error> {
        coreDataManager.createWallet(
            name: wallet.name,
            type: wallet.type.rawValue,
            balance: wallet.balance,
            icon: wallet.icon,
            color: wallet.color
        )
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func updateWallet(_ wallet: WalletModel) -> AnyPublisher<Void, Error> {
        let wallets = coreDataManager.fetchWallets()
        if let existingWallet = wallets.first(where: { $0.id == wallet.id }) {
            existingWallet.name = wallet.name
            existingWallet.type = wallet.type.rawValue
            existingWallet.balance = wallet.balance
            existingWallet.icon = wallet.icon
            coreDataManager.updateWallet(existingWallet)
        }
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func deleteWallet(_ wallet: WalletModel) -> AnyPublisher<Void, Error> {
        let wallets = coreDataManager.fetchWallets()
        if let existingWallet = wallets.first(where: { $0.id == wallet.id }) {
            coreDataManager.deleteWallet(existingWallet)
        }
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
} 
