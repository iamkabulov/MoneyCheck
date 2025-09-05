import Foundation

struct WalletModel: Identifiable, Codable {
    let id: UUID
    let name: String
    let type: ItemType
    var amount: Double
    var transactions: [TransactionModel]
    let icon: String
    let color: String

    init(
        id: UUID = UUID(),
        name: String,
        type: ItemType,
        amount: Double,
        icon: String,
        color: String,
        transactions: [TransactionModel]
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.amount = amount
        self.transactions = transactions
        self.icon = icon
        self.color = color
    }
}
