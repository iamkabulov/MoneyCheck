import Foundation
import Combine

protocol WalletRepository {
    func getWallets(period: PeriodType) -> AnyPublisher<[WalletModel], Error>
    func addWallet(_ wallet: WalletModel) -> AnyPublisher<Void, Error>
    func updateWallet(_ wallet: WalletModel) -> AnyPublisher<Void, Error>
    func deleteWallet(_ wallet: WalletModel) -> AnyPublisher<Void, Error>
    func getWallet(by id: UUID) -> AnyPublisher<WalletModel, Error>
    func deleteWallet(by id: UUID) -> AnyPublisher<Void, Error>
}
