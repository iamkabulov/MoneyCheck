import Foundation

struct CategoryModel: Identifiable, Codable {
    let id: UUID
    let name: String
    let type: CategoryType
    var amount: Double
    let icon: String
    let color: String
    var transactions: [TransactionModel]

    init(id: UUID = UUID(), name: String, type: CategoryType, amount: Double, icon: String, color: String, transactions: [TransactionModel]) {
        self.id = id
        self.name = name
        self.type = type
        self.amount = amount
        self.icon = icon
        self.color = color
        self.transactions = transactions
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
