import Foundation

struct IncomeModel: Identifiable, Codable {
    let id: UUID
    let name: String
    var amount: Double
    let icon: String
    let type: ItemType
    let color: String
    var transactions: [TransactionModel]

    init(id: UUID = UUID(), name: String, type: ItemType, amount: Double, icon: String, color: String, transactions: [TransactionModel]) {
        self.id = id
        self.name = name
        self.type = type
        self.amount = amount
        self.icon = icon
        self.color = color
        self.transactions = transactions
    }
}
