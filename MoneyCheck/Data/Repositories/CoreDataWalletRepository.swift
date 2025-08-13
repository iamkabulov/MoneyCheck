import Foundation
import Combine
import CoreData

final class CoreDataWalletRepository: WalletRepository {
    private let coreDataManager = CoreDataManager.shared

    func getWallet(by id: UUID) -> AnyPublisher<WalletModel, Error> {
        guard let wallet = coreDataManager.fetchWallet(by: id) else { return Fail(error: NSError(domain: "", code: 0, userInfo: nil)).eraseToAnyPublisher()}
        let transactions = coreDataManager.fetchTransactions(by: id)
            .map { transaction in
                TransactionModel(
                    id: transaction.id ?? UUID(),
                    date: transaction.date ?? Date(),
                    amount: transaction.amount,
                    type: TransactionType(rawValue: transaction.type ?? "") ?? .transfer,
                    sourceId: transaction.sourceId ?? UUID(),
                    sourceName: transaction.sourceName ?? "",
                    sourceIcon: transaction.sourceIcon ?? "",
                    sourceColor: transaction.sourceColor ?? "",
                    destinationId: transaction.destinationId ?? UUID(),
                    destinationName: transaction.destinationName ?? "",
                    destinationIcon: transaction.destinationIcon ?? "",
                    destinationColor: transaction.destinationColor ?? ""
                )
            }


        let result = WalletModel(
            id: wallet.id ?? UUID(),
            name: wallet.name ?? "",
            type: WalletType(rawValue: wallet.type ?? "") ?? .cash,
            balance: wallet.balance,
            icon: wallet.icon ?? "",
            color: wallet.color ?? "",
            transactions: transactions
        )
        return Just(result)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func getWallets() -> AnyPublisher<[WalletModel], Error> {
        let wallets = coreDataManager.fetchWallets()

        let walletModels = wallets.map { wallet in

            let transactions = coreDataManager
                .fetchTransactions(by: wallet.id ?? UUID())
                .map { transaction in
                    TransactionModel(
                        id: transaction.id ?? UUID(),
                        date: transaction.date ?? Date(),
                        amount: transaction.amount,
                        type: TransactionType(rawValue: transaction.type ?? "") ?? .transfer,
                        sourceId: transaction.sourceId ?? UUID(),
                        sourceName: transaction.sourceName ?? "",
                        sourceIcon: transaction.sourceIcon ?? "",
                        sourceColor: transaction.sourceColor ?? "",
                        destinationId: transaction.destinationId ?? UUID(),
                        destinationName: transaction.destinationName ?? "",
                        destinationIcon: transaction.destinationIcon ?? "",
                        destinationColor: transaction.destinationColor ?? ""
                    )
                }


            return WalletModel(
                id: wallet.id ?? UUID(),
                name: wallet.name ?? "",
                type: WalletType(rawValue: wallet.type ?? "") ?? .cash,
                balance: wallet.balance,
                icon: wallet.icon ?? "",
                color: wallet.color ?? "",
                transactions: transactions
            )
        }

        return Just(walletModels)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func addWallet(_ wallet: WalletModel) -> AnyPublisher<Void, Error> {
        let _ = coreDataManager.createWallet(
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
