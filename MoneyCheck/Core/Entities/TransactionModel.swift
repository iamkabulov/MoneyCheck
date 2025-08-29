import Foundation

enum TransactionType: String, Codable {
    case income = "Доход"
    case expense = "Расход"
    case transfer = "Перевод"
}

struct TransactionModel: Identifiable, Codable {
    let id: UUID
    let date: Date
    let amount: Double
    let comment: String?
    let type: TransactionType
    
    // Источник
    let sourceId: UUID
    let sourceName: String
    let sourceIcon: String
    let sourceColor: String
    
    // Назначение
    let destinationId: UUID
    let destinationName: String
    let destinationIcon: String
    let destinationColor: String
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        amount: Double,
        type: TransactionType,
        sourceId: UUID,
        sourceName: String,
        sourceIcon: String,
        sourceColor: String,
        destinationId: UUID,
        destinationName: String,
        destinationIcon: String,
        destinationColor: String,
        comment: String? = nil
    ) {
        self.id = id
        self.date = date
        self.amount = amount
        self.type = type
        self.sourceId = sourceId
        self.sourceName = sourceName
        self.sourceIcon = sourceIcon
        self.sourceColor = sourceColor
        self.destinationId = destinationId
        self.destinationName = destinationName
        self.destinationIcon = destinationIcon
        self.destinationColor = destinationColor
        self.comment = comment
    }
} 
