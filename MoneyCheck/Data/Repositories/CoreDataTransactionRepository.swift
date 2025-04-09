import Foundation
import CoreData
import Combine

final class CoreDataTransactionRepository: TransactionRepository {
    private let coreDataManager = CoreDataManager.shared
    
    init() {
    }
    
    func getTransactions() -> AnyPublisher<[TransactionModel], Error> {
        return Future { [weak self] promise in
            guard let self = self else { return }
            
            let transactions = self.coreDataManager.fetchTransactions()
            
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
                    destinationColor: transaction.destinationColor ?? ""
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
                destinationColor: transaction.destinationColor
            )

            promise(.success(()))
        }.eraseToAnyPublisher()
    }
    
    func updateTransaction(_ transaction: TransactionModel) -> AnyPublisher<Void, Error> {
        return Future { [weak self] promise in
            guard let self = self else { return }
            
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
                    
                    self.coreDataManager.saveContext()
                    promise(.success(()))
                } else {
                    promise(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Transaction not found"])))
                }
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
} 
