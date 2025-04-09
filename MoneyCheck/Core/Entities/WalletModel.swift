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
