import Foundation

struct IncomeModel: Identifiable, Codable {
    let id: UUID
    let name: String
    var amount: Double
    let icon: String
    let color: String
    
    init(id: UUID = UUID(), name: String, amount: Double, icon: String, color: String) {
        self.id = id
        self.name = name
        self.amount = amount
        self.icon = icon
        self.color = color
    }
}
