import Combine

protocol WalletRepository {
    func getWallets() -> AnyPublisher<[WalletModel], Error>
    func addWallet(_ wallet: WalletModel) -> AnyPublisher<Void, Error>
    func updateWallet(_ wallet: WalletModel) -> AnyPublisher<Void, Error>
    func deleteWallet(_ wallet: WalletModel) -> AnyPublisher<Void, Error>
}
