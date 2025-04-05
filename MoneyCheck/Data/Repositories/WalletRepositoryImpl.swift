import Foundation
import Combine

final class WalletRepositoryImpl: WalletRepository {
    private var wallets: [WalletModel] = [
        WalletModel(name: "Forte", type: .forte, balance: 1513, icon: "creditcard.fill"),
        WalletModel(name: "БЦК", type: .bcc, balance: 49531.72, icon: "creditcard.fill"),
        WalletModel(name: "Kaspi", type: .kaspi, balance: 700, icon: "creditcard.fill"),
        WalletModel(name: "Deposit", type: .deposit, balance: 1000000, icon: "building.columns.fill")
    ]
    
    func getWallets() -> AnyPublisher<[WalletModel], Error> {
        Just(wallets)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func addWallet(_ wallet: WalletModel) -> AnyPublisher<Void, Error> {
        wallets.append(wallet)
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func updateWallet(_ wallet: WalletModel) -> AnyPublisher<Void, Error> {
        if let index = wallets.firstIndex(where: { $0.id == wallet.id }) {
            wallets[index] = wallet
        }
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func deleteWallet(_ wallet: WalletModel) -> AnyPublisher<Void, Error> {
        wallets.removeAll { $0.id == wallet.id }
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
} 