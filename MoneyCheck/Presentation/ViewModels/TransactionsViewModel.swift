import Foundation
import Combine

struct TransactionSection {
    let date: Date
    let transactions: [TransactionModel]
    
    var totalAmount: Double {
        transactions.reduce(0) { total, transaction in
            if transaction.type == .transfer {
                if transaction.destinationId == itemId {
                    return total + transaction.amount // входящий перевод
                } else if transaction.sourceId == itemId {
                    return total - transaction.amount // исходящий перевод
                }
            } else if transaction.type == .expense {
                return total - transaction.amount
            } else {
                return total + transaction.amount
            }
            return total
        }
    }
    
    let itemId: UUID
}

class TransactionsViewModel {
    let financeUseCase: FinanceUseCase
    let itemId: UUID
    @Published private(set) var sections: [TransactionSection] = []
    private var cancellables = Set<AnyCancellable>()
    
    init(financeUseCase: FinanceUseCase, itemId: UUID) {
        self.financeUseCase = financeUseCase
        self.itemId = itemId
        loadTransactions()
    }
    
    private func loadTransactions() {
        financeUseCase.getTransactions()
            .map { transactions -> [TransactionModel] in
                let filtered = transactions.filter { transaction in
                    let isSource = transaction.sourceId == self.itemId
                    let isDestination = transaction.destinationId == self.itemId
                    return isSource || isDestination
                }
                return filtered
            }
            .map { [weak self] transactions -> [TransactionSection] in
                guard let self = self else { return [] }
                
                // Группируем транзакции по дням
                let calendar = Calendar.current
                let grouped = Dictionary(grouping: transactions) { transaction in
                    calendar.startOfDay(for: transaction.date)
                }
                
                // Сортируем дни по убыванию
                let sortedDays = grouped.keys.sorted(by: >)
                
                // Создаем секции
                return sortedDays.map { date in
                    let sectionTransactions = grouped[date]?.sorted(by: { $0.date > $1.date }) ?? []
                    return TransactionSection(date: date, transactions: sectionTransactions, itemId: self.itemId)
                }
            }
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error): break
                }
            } receiveValue: { [weak self] sections in
                self?.sections = sections
            }
            .store(in: &cancellables)
    }
    
    func updateTransaction(_ transaction: TransactionModel) {
        financeUseCase.updateTransaction(transaction)
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error): print("Error updating transaction: \(error)")
                }
            } receiveValue: { [weak self] _ in
                self?.loadTransactions()
            }
            .store(in: &cancellables)
    }
} 
