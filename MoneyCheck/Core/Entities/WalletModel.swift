import Foundation

struct WalletModel: Identifiable, Codable {
    let id: UUID
    let name: String
    let type: WalletType
    var balance: Double
    var transactions: [TransactionModel]
    let icon: String
    let color: String

    init(id: UUID = UUID(), name: String, type: WalletType, balance: Double, icon: String, color: String, transactions: [TransactionModel]) {
        self.id = id
        self.name = name
        self.type = type
        self.balance = balance
        self.transactions = transactions
        self.icon = icon
        self.color = color
    }
}

enum WalletType: String, Codable, CaseIterable {
    case cash = "Наличные"
    case card = "Карта"
    case deposit = "Депозит"
}
