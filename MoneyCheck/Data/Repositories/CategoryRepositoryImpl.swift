import Foundation
import Combine

final class CategoryRepositoryImpl: CategoryRepository {
    private var categories: [CategoryModel] = CategoryModel.mockExpenses

    func getCategories() -> AnyPublisher<[CategoryModel], Error> {
        Just(categories)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func addCategory(_ category: CategoryModel) -> AnyPublisher<Void, Error> {
        categories.append(category)
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func updateCategory(_ category: CategoryModel) -> AnyPublisher<Void, Error> {
        if let index = categories.firstIndex(where: { $0.id == category.id }) {
            categories[index] = category
        }
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func deleteCategory(_ category: CategoryModel) -> AnyPublisher<Void, Error> {
        categories.removeAll { $0.id == category.id }
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
} 
