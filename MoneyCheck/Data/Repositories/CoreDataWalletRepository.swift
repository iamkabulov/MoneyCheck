import Foundation
import Combine
import CoreData

final class CoreDataWalletRepository: WalletRepository {
    private let coreDataManager = CoreDataManager.shared
    
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

            // 📌 Пересчёт баланса на основе транзакций
            let calculatedBalance = calculateBalance(for: wallet.id ?? UUID(), transactions: transactions)

            return WalletModel(
                id: wallet.id ?? UUID(),
                name: wallet.name ?? "",
                type: WalletType(rawValue: wallet.type ?? "") ?? .cash,
                balance: calculatedBalance,
                icon: wallet.icon ?? "",
                color: wallet.color ?? "",
                transactions: transactions
            )
        }

        return Just(walletModels)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    /// Вынос логики пересчёта в отдельный метод
    private func calculateBalance(for walletId: UUID, transactions: [TransactionModel]) -> Double {
        transactions.reduce(0) { partial, transaction in
            switch transaction.type {
            case .income:
                return partial + transaction.amount
            case .expense:
                return partial - transaction.amount
            case .transfer:
                if transaction.sourceId == walletId {
                    return partial - transaction.amount
                } else if transaction.destinationId == walletId {
                    return partial + transaction.amount
                }
                return partial
            }
        }
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
