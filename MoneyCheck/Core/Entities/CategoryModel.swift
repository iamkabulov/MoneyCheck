import Foundation

struct CategoryModel: Identifiable, Codable {
    let id: UUID
    let name: String
    let type: CategoryType
    var amount: Double
    let icon: String
    let color: String
    
    init(id: UUID = UUID(), name: String, type: CategoryType, amount: Double, icon: String, color: String) {
        self.id = id
        self.name = name
        self.type = type
        self.amount = amount
        self.icon = icon
        self.color = color
    }
}

enum CategoryType: String, Codable, CaseIterable {
    case expense = "Расход"
    case income = "Доход"
}

enum ExpenseCategory: String, Codable {
    case products = "Продукты"
    case transport = "Транспорт"
    case fastFood = "Фаст фуд"
    case subscriptions = "Подписки"
    case entertainment = "Развлечения"
    case repair = "Ремонт"
    case health = "Здоровье"
    case travel = "Путешествия"
    case credits = "Кредиты"
    case gifts = "Подарки"
}

// MARK: - Mock Data
extension CategoryModel {
    static let mockExpenses: [CategoryModel] = [
        CategoryModel(name: ExpenseCategory.products.rawValue, type: .expense, amount: 0, icon: "cart.fill", color: "systemRed"),
        CategoryModel(name: ExpenseCategory.transport.rawValue, type: .expense, amount: 0, icon: "car.fill", color: "systemRed"),
        CategoryModel(name: ExpenseCategory.fastFood.rawValue, type: .expense, amount: 0, icon: "takeoutbag.and.cup.and.straw.fill", color: "systemRed"),
        CategoryModel(name: ExpenseCategory.subscriptions.rawValue, type: .expense, amount: 0, icon: "star.fill", color: "systemRed"),
        CategoryModel(name: ExpenseCategory.entertainment.rawValue, type: .expense, amount: 0, icon: "tv.fill", color: "systemRed"),
        CategoryModel(name: ExpenseCategory.repair.rawValue, type: .expense, amount: 0, icon: "hammer.fill", color: "systemRed"),
        CategoryModel(name: ExpenseCategory.health.rawValue, type: .expense, amount: 0, icon: "heart.fill", color: "systemRed"),
        CategoryModel(name: ExpenseCategory.travel.rawValue, type: .expense, amount: 0, icon: "airplane", color: "systemRed"),
        CategoryModel(name: ExpenseCategory.credits.rawValue, type: .expense, amount: 0, icon: "creditcard.fill", color: "systemRed"),
        CategoryModel(name: ExpenseCategory.gifts.rawValue, type: .expense, amount: 0, icon: "gift.fill", color: "systemRed")
    ]
} 
