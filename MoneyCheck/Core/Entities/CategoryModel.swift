import Foundation

struct CategoryModel: Identifiable, Codable {
    let id: UUID
    let name: String
    let type: CategoryType
    var amount: Double
    let icon: String
    
    init(id: UUID = UUID(), name: String, type: CategoryType, amount: Double, icon: String) {
        self.id = id
        self.name = name
        self.type = type
        self.amount = amount
        self.icon = icon
    }
}

enum CategoryType: String, Codable {
    case income
    case expense
    
    var title: String {
        switch self {
        case .income:
            return "Доходы"
        case .expense:
            return "Расходы"
        }
    }
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