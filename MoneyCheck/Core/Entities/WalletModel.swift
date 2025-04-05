import Foundation

struct WalletModel: Identifiable, Codable {
    let id: UUID
    let name: String
    let type: WalletType
    var balance: Double
    let icon: String
    
    init(id: UUID = UUID(), name: String, type: WalletType, balance: Double, icon: String) {
        self.id = id
        self.name = name
        self.type = type
        self.balance = balance
        self.icon = icon
    }
}

enum WalletType: String, Codable {
    case forte
    case bcc
    case kaspi
    case deposit
} 