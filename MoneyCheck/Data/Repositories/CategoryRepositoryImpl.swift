import Foundation
import Combine

final class CategoryRepositoryImpl: CategoryRepository {
    private var categories: [CategoryModel] = [
        CategoryModel(name: "Продукты", type: .expense, amount: 0, icon: "cart.fill"),
        CategoryModel(name: "Транспорт", type: .expense, amount: 0, icon: "car.fill"),
        CategoryModel(name: "Фаст фуд", type: .expense, amount: 0, icon: "takeoutbag.and.cup.and.straw.fill"),
        CategoryModel(name: "Подписки", type: .expense, amount: 0, icon: "star.circle.fill"),
        CategoryModel(name: "Развлечения", type: .expense, amount: 0, icon: "tv.fill"),
        CategoryModel(name: "Ремонт", type: .expense, amount: 0, icon: "hammer.fill"),
        CategoryModel(name: "Здоровье", type: .expense, amount: 0, icon: "heart.fill"),
        CategoryModel(name: "Путешествия", type: .expense, amount: 0, icon: "airplane"),
        CategoryModel(name: "Кредиты", type: .expense, amount: 0, icon: "creditcard.fill"),
        CategoryModel(name: "Подарки", type: .expense, amount: 0, icon: "gift.fill"),
        CategoryModel(name: "Доход", type: .income, amount: 300000, icon: "dollarsign.circle.fill")
    ]
    
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