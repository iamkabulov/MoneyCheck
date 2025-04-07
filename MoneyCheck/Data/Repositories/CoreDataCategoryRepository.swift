import Foundation
import Combine
import CoreData

final class CoreDataCategoryRepository: CategoryRepository {
    private let coreDataManager = CoreDataManager.shared
    
    func getCategories() -> AnyPublisher<[CategoryModel], Error> {
        let categories = coreDataManager.fetchCategories()
        let categoryModels = categories.map { category in
            CategoryModel(
                id: category.id ?? UUID(),
                name: category.name ?? "",
                type: CategoryType(rawValue: category.type ?? "") ?? .expense,
                amount: category.amount,
                icon: category.icon ?? "",
                color: category.color ?? ""
            )
        }
        return Just(categoryModels)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func addCategory(_ category: CategoryModel) -> AnyPublisher<Void, Error> {
        coreDataManager.createCategory(
            name: category.name,
            type: category.type.rawValue,
            amount: category.amount,
            icon: category.icon,
            color: category.color
        )
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