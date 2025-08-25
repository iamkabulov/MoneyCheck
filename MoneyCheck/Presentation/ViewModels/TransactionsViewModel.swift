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
    let itemType: ItemType
    @Published private(set) var sections: [TransactionSection] = []
    private let router: TransactionsRouting
    private var cancellables = Set<AnyCancellable>()
    private let period: PeriodType

    init(
        financeUseCase: FinanceUseCase,
        itemId: UUID,
        itemType: ItemType,
        router: TransactionsRouting,
        period: PeriodType
    ) {
        self.financeUseCase = financeUseCase
        self.itemId = itemId
        self.itemType = itemType
        self.router = router
        self.period = period
        loadTransactions(by: itemId, period: period)
    }
    
    private func loadTransactions(by id: UUID, period: PeriodType) {
        financeUseCase.getTransactions(by: id, period: period)
            .map { [weak self] transactions -> [TransactionSection] in
                guard let self = self else { return [] }
//                let transactions = transactions.filter { transaction in
//                    switch period {
//                        case .custom(let startDate, let endDate):
//                            return transaction.date >= startDate && transaction.date <= endDate
//                        default:
//                            break
//                    }
//                    return false
//                }

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
                    case .failure(let error):
                        self.router.showError("Error", message: error.localizedDescription)
                }
            } receiveValue: { [weak self] sections in
                self?.sections = sections
            }
            .store(in: &cancellables)
    }

    func showEditItemView(id: UUID, itemType: ItemType) {
        router.showEditItemView(id: id, type: itemType)
    }

    func updateTransaction(_ transaction: TransactionModel) {
        financeUseCase.updateTransaction(transaction)
            .sink { completion in
                switch completion {
                    case .finished: break
                    case .failure(let error):
                        self.router.showError("Error", message: error.localizedDescription)
                }
            } receiveValue: { [weak self] _ in
                guard let self else { return }
                self.loadTransactions(by: self.itemId, period: period)
            }
            .store(in: &cancellables)

        financeUseCase.getIncome(by: transaction.sourceId)
            .sink { completion in
                switch completion {
                    case .finished: break
                    case .failure(let error):
                        self.router.showError("Error", message: error.localizedDescription)
                }
            } receiveValue: { income in
                let calculatedBalance = self.calculateBalance(
                    for: income.id,
                    transactions: income.transactions
                )
                var result = income
                result.amount = calculatedBalance
                let _ = self.financeUseCase.updateIncome(result)
            }
            .store(in: &cancellables)

        financeUseCase.getWallet(by: transaction.destinationId)
            .sink { completion in
                switch completion {
                    case .finished: break
                    case .failure(let error):
                        self.router.showError("Error", message: error.localizedDescription)
                }
            } receiveValue: { wallet in
                let calculatedBalance = self.calculateBalance(
                    for: wallet.id,
                    transactions: wallet.transactions
                )
                var result = wallet
                result.balance = calculatedBalance
                let _ = self.financeUseCase.updateWallet(result)
            }
            .store(in: &cancellables)

        financeUseCase.getWallet(by: transaction.sourceId)
            .sink { completion in
                switch completion {
                    case .finished: break
                    case .failure(let error):
                        self.router.showError("Error", message: error.localizedDescription)
                }
            } receiveValue: { wallet in
                let calculatedBalance = self.calculateBalance(
                    for: wallet.id,
                    transactions: wallet.transactions
                )
                var result = wallet
                result.balance = calculatedBalance
                let _ = self.financeUseCase.updateWallet(result)
            }
            .store(in: &cancellables)

        financeUseCase.getCategory(by: transaction.destinationId)
            .sink { completion in
                switch completion {
                    case .finished: break
                    case .failure(let error):
                        self.router.showError("Error", message: error.localizedDescription)
                }
            } receiveValue: { category in
                let calculatedBalance = self.calculateBalance(
                    for: category.id,
                    transactions: category.transactions
                )
                var result = category
                result.amount = calculatedBalance
                let _ = self.financeUseCase.updateCategory(result)
            }
            .store(in: &cancellables)

    }

    private func calculateBalance(for walletId: UUID, transactions: [TransactionModel]) -> Double {
        transactions.reduce(0) { partial, transaction in
            switch transaction.type {
            case .income:
                return partial + transaction.amount
            case .expense:
                return partial - transaction.amount
            case .transfer:
                if transaction.sourceId == walletId {
                    return partial - transaction.amount
                } else if transaction.destinationId == walletId {
                    return partial + transaction.amount
                }
                return partial
            }
        }
    }
}
