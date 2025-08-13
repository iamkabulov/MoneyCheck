import Foundation
import Combine
import CoreData

final class CoreDataCategoryRepository: CategoryRepository {

    private let coreDataManager = CoreDataManager.shared

    func getCategory(by id: UUID) -> AnyPublisher<CategoryModel, any Error> {
        guard let category = coreDataManager.fetchCategory(by: id) else { return Fail(error: NSError(domain: "", code: 0, userInfo: nil)).eraseToAnyPublisher()}
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

        let result = CategoryModel(
            id: category.id ?? UUID(),
            name: category.name ?? "",
            type: .expense,
            amount: category.amount,
            icon: category.icon ?? "",
            color: category.color ?? "",
            transactions: transactions
        )

        return Just(result)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

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

            return CategoryModel(
                id: category.id ?? UUID(),
                name: category.name ?? "",
                type: CategoryType(rawValue: category.type ?? "") ?? .expense,
                amount: abs(category.amount),
                icon: category.icon ?? "",
                color: category.color ?? "",
                transactions: transactions
            )
        }
        return Just(categoryModels)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func addCategory(_ category: CategoryModel) -> AnyPublisher<Void, Error> {
        let _ = coreDataManager
            .createCategory(name: category.name,
                            type: category.type.rawValue,
                            amount: category.amount,
                            icon: category.icon,
                            color: category.color)
        
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
