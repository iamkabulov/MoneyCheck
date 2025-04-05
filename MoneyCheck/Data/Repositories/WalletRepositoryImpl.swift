import Foundation
import Combine

final class WalletRepositoryImpl: WalletRepository {
    private var wallets: [WalletModel] = WalletModel.mockData

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
