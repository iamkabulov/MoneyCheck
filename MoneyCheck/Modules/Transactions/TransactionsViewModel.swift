import Foundation
import Combine

struct ChartBarData {
    let title: String      // что показывать внизу (янв., 1 сент.)
    let total: Double      // общая сумма расходов
}

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

typealias UseCase = TransactionsIntervalUserCaseProtocol & TransactionsUseCaseProtocol

final class TransactionsViewModel: BaseViewModel<TransactionsRouterProtocol, UseCase> {
    let itemId: UUID
    let itemType: ItemType
    @Published var periodTitle: String = ""
    @Published private(set) var sections: [TransactionSection] = []
    @Published private(set) var stats: (Double, Double) = (0, 0)
    private var transactions: [TransactionModel] = []
    @Published private(set) var barCharts: [ChartBarData] = []
    private var cancellables = Set<AnyCancellable>()
    var period: PeriodType
    private var currentDate: Date = Date()
    private let calendar = Calendar.current

    init(
        useCase: UseCase,
        itemId: UUID,
        itemType: ItemType,
        router: TransactionsRouterProtocol,
        period: PeriodType
    ) {
        self.itemId = itemId
        self.itemType = itemType
        self.period = period
        super.init(useCase: useCase, router: router)
        updatePeriodTitle()
        let interval = makeDateInterval(for: period, basedOn: currentDate)
        getTransactions(start: interval.start, end: interval.end)
    }

    deinit {
        print("Deinit TransactionsViewModel")
    }

    func loadPeriod() {
        useCase.getPeriod()
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Error loading data: \(error)")
                }
            }
        receiveValue: { [weak self] loadedPeriod in
            guard let self = self else { return }
            self.period = loadedPeriod
            // обновляем заголовок и перезагружаем данные под новый период
            self.updatePeriodTitle()
            let interval = self.makeDateInterval(for: self.period, basedOn: self.currentDate)
            self.getTransactions(start: interval.start, end: interval.end)
        }
        .store(in: &cancellables)
    }

    //    func loadTransactions(by id: UUID, period: PeriodType) {
    //        useCase.getTransactions(by: id, period: period)
    //            .map { [weak self] transactions -> [TransactionSection] in
    //                guard let self = self else { return [] }
    ////                let transactions = transactions.filter { transaction in
    ////                    switch period {
    ////                        case .custom(let startDate, let endDate):
    ////                            return transaction.date >= startDate && transaction.date <= endDate
    ////                        default:
    ////                            break
    ////                    }
    ////                    return false
    ////                }
    //                self.transactions = transactions
    //                // Группируем транзакции по дням
    //                let calendar = Calendar.current
    //                let grouped = Dictionary(grouping: transactions) { transaction in
    //                    calendar.startOfDay(for: transaction.date)
    //                }
    //
    //                // Сортируем дни по убыванию
    //                let sortedDays = grouped.keys.sorted(by: >)
    //
    //                // Создаем секции
    //                return sortedDays.map { date in
    //                    let sectionTransactions = grouped[date]?.sorted(by: { $0.date > $1.date }) ?? []
    //                    return TransactionSection(date: date, transactions: sectionTransactions, itemId: self.itemId)
    //                }
    //            }
    //            .sink { completion in
    //                switch completion {
    //                    case .finished: break
    //                    case .failure(let error):
    //                        self.router.showError("Error", message: error.localizedDescription)
    //                }
    //            } receiveValue: { [weak self] sections in
    //                self?.sections = sections
    //            }
    //            .store(in: &cancellables)
    //    }

    func loadFurtherTransactions(forward: Bool) {
        let value = forward ? 1 : -1

        switch period {
            case .week:
                guard let newDate = calendar.date(byAdding: .weekOfYear, value: value, to: currentDate) else { return }
                currentDate = newDate
                let interval = makeDateInterval(for: period, basedOn: currentDate)
                updatePeriodTitle()
                getTransactions(start: interval.start, end: interval.end)

            case .month:
                guard let newDate = calendar.date(byAdding: .month, value: value, to: currentDate) else { return }
                currentDate = newDate
                let interval = makeDateInterval(for: period, basedOn: currentDate)
                updatePeriodTitle()
                getTransactions(start: interval.start, end: interval.end)

            case .custom(let startDate, let endDate):
                // сдвигаем кастомный диапазон на его длину (days + 1)
                let days = calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 0
                guard let newStart = calendar.date(byAdding: .day, value: value * (days + 1), to: startDate),
                      let newEnd = calendar.date(byAdding: .day, value: value * (days + 1), to: endDate)
                else { return }

                let newPeriod = PeriodType.custom(newStart, newEnd)
                self.period = newPeriod
                // ставим currentDate в начало нового диапазона (можно в mid, если нужно)
                self.currentDate = newStart
                updatePeriodTitle(for: newPeriod)
                getTransactions(start: newStart, end: newEnd)
                return // важно: не выполнять общий код ниже

            case .lastMonth, .wholeTime:
                // если перелистывать не имеет смысла — игнорируем
                return
        }
    }

    private func getTransactions(start: Date, end: Date) {
        useCase.getTransactionsForInterval(by: itemId, start: start, end: end)
            .map { [weak self] transactions -> [TransactionSection] in
                guard let self = self else { return [] }

                self.transactions = transactions

                let grouped = Dictionary(grouping: transactions) { transaction in
                    self.calendar.startOfDay(for: transaction.date)
                }
                let sortedDays = grouped.keys.sorted(by: >)

                return sortedDays.map { date in
                    let sectionTransactions = grouped[date]?.sorted(by: { $0.date > $1.date }) ?? []
                    return TransactionSection(date: date, transactions: sectionTransactions, itemId: self.itemId)
                }
            }
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.router.showError("Error", message: error.localizedDescription)
                }
            } receiveValue: { [weak self] sections in
                self?.sections = sections
            }
            .store(in: &cancellables)

        calculateExpenses(start: start, end: end)
        barCharts = generateChartData(for: period)
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

    private func makeDateInterval(for period: PeriodType, basedOn date: Date) -> (start: Date, end: Date) {
        switch period {
            case .week:
                guard let start = calendar.dateInterval(of: .weekOfYear, for: date)?.start,
                      let end = calendar.date(byAdding: .day, value: 6, to: start) else { return (Date(), Date()) }
                return (start, end)

            case .month:
                guard let start = calendar.dateInterval(of: .month, for: date)?.start,
                      let range = calendar.range(of: .day, in: .month, for: date),
                      let end = calendar.date(byAdding: .day, value: range.count - 1, to: start) else {
                    return (Date(), Date())
                }
                return (start, end)

            case .custom(let startDate, let endDate):
                return (startDate, endDate)

            case .wholeTime, .lastMonth: return (Date(), Date())
        }
    }

    private func updatePeriodTitle(for customPeriod: PeriodType? = nil) {
        let title = makePeriodTitle(for: customPeriod ?? period, basedOn: currentDate)
        self.periodTitle = title
    }

    private func makePeriodTitle(for period: PeriodType, basedOn date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")

        switch period {
            case .week:
                let interval = calendar.dateInterval(of: .weekOfYear, for: date)!
                formatter.dateFormat = "dd.MM"
                let startString = formatter.string(from: interval.start)
                let endString = formatter.string(from: calendar.date(byAdding: .day, value: 6, to: interval.start)!)
                return "\(startString) - \(endString)"

            case .month:
                formatter.dateFormat = "LLLL yyyy"
                return  formatter.string(from: date).capitalized

            case .custom(let startDate, let endDate):
                formatter.dateFormat = "dd.MM"
                return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"

            default: return ""
                //        case .lastMonth:
                //            let currentMonth = calendar.dateInterval(of: .month, for: date)!
                //            let lastMonthEnd = calendar.date(byAdding: .day, value: -1, to: currentMonth.start)!
                //            formatter.dateFormat = "LLLL yyyy"
                //            return formatter.string(from: lastMonthEnd).capitalized
                //
                //        case .wholeTime:
                //            return "За всё время"
        }
    }

    private func calculateExpenses(start: Date, end: Date) {
        let total = transactions.reduce(0) { $0 + $1.amount }

        let days = calendar.dateComponents([.day], from: start, to: end).day ?? 1
        let average = total / Double(days)

        self.stats = (total, average)
    }

    //TODO: - Нужно подумать как сделать
    private func generateChartData(for period: PeriodType, count: Int = 14) -> [ChartBarData] {
        var result: [ChartBarData] = []
        let calendar = Calendar.current
        let now = Date()

        for offset in stride(from: -count + 1, through: 0, by: 1) {
            switch period {
                case .week:
                    if let date = calendar.date(byAdding: .weekOfYear, value: offset, to: now),
                       let interval = calendar.dateInterval(of: .weekOfYear, for: date) {
                        useCase.getTransactionsForInterval(by: itemId, start: interval.start, end: interval.end)
                            .sink(receiveCompletion: { completion in
                                // обработка ошибок
                            }, receiveValue: { transactions in
                                let total = transactions.reduce(0) { $0 + $1.amount }

                                let formatter = DateFormatter()
                                formatter.dateFormat = "d MMM"
                                let title = formatter.string(from: interval.start)

                                result.append(ChartBarData(title: title, total: total))
                            })
                            .store(in: &cancellables)
                    }

                case .month:
                    if let date = calendar.date(byAdding: .month, value: offset, to: now),
                       let interval = calendar.dateInterval(of: .month, for: date) {
                        useCase.getTransactionsForInterval(by: itemId, start: interval.start, end: interval.end)
                            .sink(receiveCompletion: { completion in
                                // обработка ошибок
                            }, receiveValue: { transactions in
                                let filtered = transactions.filter { $0.date >= interval.start && $0.date < interval.end }
                                let total = filtered.reduce(0) { $0 + $1.amount }

                                let monthSymbol = calendar.shortMonthSymbols[calendar.component(.month, from: date) - 1]
                                result.append(ChartBarData(title: monthSymbol, total: total))
                            })
                            .store(in: &cancellables)
                    }

                case .custom(let start, let end):
                    useCase.getTransactionsForInterval(by: itemId, start: start, end: end)
                        .sink(receiveCompletion: { completion in
                            // обработка ошибок
                        }, receiveValue: { transactions in
                            let filtered = transactions.filter { $0.date >= start && $0.date < end }
                            let total = filtered.reduce(0) { $0 + $1.amount }

                            let formatter = DateFormatter()
                            formatter.dateFormat = "d MMM"
                            let title = formatter.string(from: start)

                            result.append(ChartBarData(title: title, total: total))
                        })
                        .store(in: &cancellables)
                default:
                    break
            }
        }
        return result
    }

}
