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

enum WalletType: String, Codable, CaseIterable {
    case cash = "Наличные"
    case card = "Карта"
    case deposit = "Депозит"
    
    var icon: String {
        switch self {
        case .cash:
            return "banknote.fill"
        case .card:
            return "creditcard.fill"
        case .deposit:
            return "building.columns.fill"
        }
    }
    
    var color: String {
        switch self {
        case .cash:
            return "#34C759" // systemGreen
        case .card:
            return "#007AFF" // systemBlue
        case .deposit:
            return "#AF52DE" // systemPurple
        }
    }
}

// MARK: - Mock Data
extension WalletModel {
    static let mockData: [WalletModel] = [
        WalletModel(name: "Наличные", type: .cash, balance: 1513, icon: "banknote"),
        WalletModel(name: "Карта", type: .card, balance: 49531.72, icon: "creditcard"),
        WalletModel(name: "Дебетовая карта", type: .card, balance: 700, icon: "creditcard"),
        WalletModel(name: "Депозит", type: .deposit, balance: 1000000, icon: "bank")
    ]
} 
