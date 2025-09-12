import Foundation
import CoreData
import Combine

protocol TransactionRepositoryProtocol {
    func getTransactions(by id: UUID, period: PeriodType) -> AnyPublisher<[TransactionModel], Error>
    func addTransaction(_ transaction: TransactionModel) -> AnyPublisher<Void, Error>
    func updateTransaction(_ transaction: TransactionModel) -> AnyPublisher<Void, Error>
    func deleteTransaction(by id: UUID) -> AnyPublisher<Void, Error>
}

final class CoreDataTransactionRepository: TransactionRepositoryProtocol {
    private let coreDataManager = CoreDataManager.shared

    func getTransactions(by id: UUID, period: PeriodType) -> AnyPublisher<[TransactionModel], Error> {
        return Future { [weak self] promise in
            guard let self = self else { return }

            let transactions = self.coreDataManager.fetchTransactions(by: id, period: period)

            let models = transactions.map { transaction in
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
                    destinationColor: transaction.destinationColor ?? "",
                    comment: transaction.comment
                )
            }
            promise(.success(models))
        }.eraseToAnyPublisher()
    }

    func addTransaction(_ transaction: TransactionModel) -> AnyPublisher<Void, Error> {
        
        return Future { [weak self] promise in
            guard let self = self else { return }
            
            _ = self.coreDataManager.createTransaction(
                id: transaction.id,
                date: transaction.date,
                amount: transaction.amount,
                type: transaction.type.rawValue,
                sourceId: transaction.sourceId,
                sourceName: transaction.sourceName,
                sourceIcon: transaction.sourceIcon,
                sourceColor: transaction.sourceColor,
                destinationId: transaction.destinationId,
                destinationName: transaction.destinationName,
                destinationIcon: transaction.destinationIcon,
                destinationColor: transaction.destinationColor,
                comment: transaction.comment
            )

            promise(.success(()))
        }.eraseToAnyPublisher()
    }
    
    func updateTransaction(_ transaction: TransactionModel) -> AnyPublisher<Void, Error> {
            let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", transaction.id as CVarArg)
            
            do {
                let transactions = try self.coreDataManager.context.fetch(request)
                if let existingTransaction = transactions.first {
                    existingTransaction.date = transaction.date
                    existingTransaction.amount = transaction.amount
                    existingTransaction.type = transaction.type.rawValue
                    existingTransaction.sourceId = transaction.sourceId
                    existingTransaction.sourceName = transaction.sourceName
                    existingTransaction.sourceIcon = transaction.sourceIcon
                    existingTransaction.sourceColor = transaction.sourceColor
                    existingTransaction.destinationId = transaction.destinationId
                    existingTransaction.destinationName = transaction.destinationName
                    existingTransaction.destinationIcon = transaction.destinationIcon
                    existingTransaction.destinationColor = transaction.destinationColor
                    existingTransaction.comment = transaction.comment

                    self.coreDataManager.saveContext()
                }
            } catch {
                return Fail(error: error).eraseToAnyPublisher()
            }
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func deleteTransaction(by id: UUID) -> AnyPublisher<Void, Error> {
        coreDataManager.deleteTransaction(by: id)
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
