import Foundation
import Combine
import CoreData

final class CoreDataCategoryRepository: CategoryRepository {
    private let coreDataManager = CoreDataManager.shared
    
    func getCategories() -> AnyPublisher<[CategoryModel], Error> {
        let categories = coreDataManager.fetchCategories()
        let categoryModels = categories.map { category in
            
            let transactions = coreDataManager
                .fetchTransactions(by: category.id ?? UUID())
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

            // 📌 Пересчёт баланса
            let calculatedBalance = calculateBalance(for: category.id ?? UUID(), transactions: transactions)

            return CategoryModel(
                id: category.id ?? UUID(),
                name: category.name ?? "",
                type: CategoryType(rawValue: category.type ?? "") ?? .expense,
                amount: abs(calculatedBalance),
                icon: category.icon ?? "",
                color: category.color ?? "",
                transactions: transactions
            )
        }
        return Just(categoryModels)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

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

    func addCategory(_ category: CategoryModel) -> AnyPublisher<Void, Error> {
        let newCategory = Category(context: coreDataManager.context)
        newCategory.id = category.id
        newCategory.name = category.name
        newCategory.type = category.type.rawValue
        newCategory.amount = category.amount
        newCategory.icon = category.icon
        newCategory.color = category.color
        coreDataManager.saveContext()
        
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func updateCategory(_ category: CategoryModel) -> AnyPublisher<Void, Error> {
        let categories = coreDataManager.fetchCategories()
        if let existingCategory = categories.first(where: { $0.id == category.id }) {
            existingCategory.name = category.name
            existingCategory.type = category.type.rawValue
            existingCategory.amount = category.amount
            existingCategory.icon = category.icon
            existingCategory.color = category.color
            coreDataManager.updateCategory(existingCategory)
        }
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func deleteCategory(_ category: CategoryModel) -> AnyPublisher<Void, Error> {
        let categories = coreDataManager.fetchCategories()
        if let existingCategory = categories.first(where: { $0.id == category.id }) {
            coreDataManager.deleteCategory(existingCategory)
        }
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
} 
