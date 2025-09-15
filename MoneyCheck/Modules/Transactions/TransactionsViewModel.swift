import Foundation
import Combine

struct TransactionSection {
    let date: Date
    let transactions: [TransactionModel]
    let itemId: UUID

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
}

final class TransactionsViewModel: BaseViewModel<TransactionsRouterProtocol, TransactionsUseCaseProtocol> {
    let itemId: UUID
    let itemType: ItemType
    @Published private(set) var sections: [TransactionSection] = []
    private var cancellables = Set<AnyCancellable>()
    let period: PeriodType

    init(
        useCase: TransactionsUseCaseProtocol,
        itemId: UUID,
        itemType: ItemType,
        router: TransactionsRouterProtocol,
        period: PeriodType
    ) {
        self.itemId = itemId
        self.itemType = itemType
        self.period = period
        super.init(useCase: useCase, router: router)
        loadTransactions(by: itemId, period: period)
    }

    deinit {
        print("Deinit TransactionsViewModel")
    }

    func loadTransactions(by id: UUID, period: PeriodType) {
        useCase.getTransactions(by: id, period: period)
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

    func showEditTransaction(for transaction: TransactionModel) {
        router.showTransactionEditView(transaction)
    }

    func openSelectPeriod() {
        router.openSelectPeriod()
    }
}
