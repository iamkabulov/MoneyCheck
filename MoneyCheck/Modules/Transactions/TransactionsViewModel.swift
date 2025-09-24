import Foundation
import Combine

struct ChartBarData {
    let startDate: Date
    let endDate: Date
    let title: String
    let total: Double
    let average: Double
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
    @Published var sections: [TransactionSection] = []
    //    @Published private(set) var stats: (Double, Double) = (0, 0)
    private var transactions: [TransactionModel] = []
    @Published var barCharts: [ChartBarData] = []
    private var cancellables = Set<AnyCancellable>()
    var period: PeriodType
    var currentDate: Date {
        didSet {
            updatePeriodTitle()
        }
    }
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
        self.currentDate = switch period {
            case .month: Date()
            case .week: Date()
            case .custom(let startDate, _): startDate
            default: Date()
        }
        super.init(useCase: useCase, router: router)
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
            let interval = self.makeDateInterval(for: self.period, basedOn: self.currentDate)
            self.currentDate = interval.start
            self.getTransactions(start: interval.start, end: interval.end)
        }
        .store(in: &cancellables)
        barCharts = generateChartData(for: period)
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

    func loadTransactions(startDate: Date, endDate: Date) {
        switch period {
            case .week:
                self.currentDate = startDate
                getTransactions(start: startDate, end: endDate)

            case .month:
                self.currentDate = startDate
                getTransactions(start: startDate, end: endDate)

            case .custom:
                guard let newPeriod = PeriodType.from(id: 3, from: startDate, to: endDate) else {
                    return
                }
                self.period = newPeriod
                self.currentDate = startDate
                getTransactions(start: startDate, end: endDate)
                return // важно: не выполнять общий код ниже

            case .lastMonth, .wholeTime: return
        }
    }

    private func getTransactions(start: Date, end: Date) {
        useCase.getTransactionsForInterval(by: itemId, start: start, end: end)
            .map { [weak self] transactions -> [TransactionSection] in
                guard let self = self else { return [] }

                self.transactions = transactions
                guard !transactions.isEmpty else { return [] } // если пусто — вернём []

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
        }
    }

    private func generateChartData(for period: PeriodType) -> [ChartBarData] {
        var result: [ChartBarData] = []
        useCase.getTransactions(by: itemId, period: .wholeTime)
            .sink(receiveCompletion: { completion in
                // обработка ошибок
            }, receiveValue: { transactions in
                let calendar = Calendar.current
                guard let minDate = transactions.map(\.date).min(),
                      let maxDate = transactions.map(\.date).max() else { return }

                switch period {
                    case .week:
                        if let start = calendar.dateInterval(of: .weekOfYear, for: minDate)?.start,
                           let end = calendar.dateInterval(of: .weekOfYear, for: maxDate)?.end {
                            var current = start
                            while current < end {
                                guard let interval = calendar.dateInterval(of: .weekOfYear, for: current) else { break }
                                let filtered = transactions.filter { $0.date >= interval.start && $0.date < interval.end }
                                let total = filtered.reduce(0) { $0 + $1.amount }

                                let formatter = DateFormatter()
                                formatter.dateFormat = "d MMM"
                                let title = formatter.string(from: current)

                                let average = total / 7.0
                                result.append(ChartBarData(startDate: interval.start, endDate: interval.end, title: title, total: total, average: average))
                                current = calendar.date(byAdding: .weekOfYear, value: 1, to: current) ?? interval.end
                            }
                        }

                    case .month:
                        if let start = calendar.dateInterval(of: .month, for: minDate)?.start,
                           let end = calendar.dateInterval(of: .month, for: maxDate)?.end {
                            var current = start
                            while current < end {
                                guard let interval = calendar.dateInterval(of: .month, for: current) else { break }
                                let filtered = transactions.filter { $0.date >= interval.start && $0.date < interval.end }
                                let total = filtered.reduce(0) { $0 + $1.amount }
                                let days = calendar.dateComponents([.day], from: interval.start, to: interval.end).day ?? 1
                                let monthSymbol = calendar.shortMonthSymbols[calendar.component(.month, from: current) - 1]
                                let average = total / Double(days)
                                result.append(ChartBarData(startDate: interval.start, endDate: interval.end, title: monthSymbol, total: total, average: average))
                                current = calendar.date(byAdding: .month, value: 1, to: current) ?? interval.end
                            }
                        }
                    case .custom(let start, let end):
                        // Длина периода в днях (включительно)
                        let days = (calendar.dateComponents([.day], from: start, to: end).day ?? 0) + 1

                        let formatter = DateFormatter()
                        formatter.dateFormat = "d MMM"

                        func makeData(from: Date, to: Date) -> ChartBarData {
                            let filtered = transactions.filter { $0.date >= from && $0.date <= to }
                            let total = filtered.reduce(0) { $0 + $1.amount }
                            let average = total / Double(max(days, 1))
                            let title = formatter.string(from: from)
                            return ChartBarData(startDate: from, endDate: to, title: title, total: total, average: average)
                        }

                        // 🔹 1. Левая часть (minDate → start-1)
                        if minDate < start {
                            let leftEnd = calendar.date(byAdding: .day, value: -1, to: start) ?? start
                            result.append(makeData(from: minDate, to: leftEnd))
                        }

                        // 🔹 2. Основные шаги назад от start
                        var backwardStart = start
                        while backwardStart >= minDate {
                            let backwardEnd = calendar.date(byAdding: .day, value: days - 1, to: backwardStart) ?? backwardStart
                            result.insert(makeData(from: backwardStart, to: backwardEnd), at: 0)
                            backwardStart = calendar.date(byAdding: .day, value: -days, to: backwardStart) ?? minDate
                        }

                        // 🔹 EXTRA: добавить чарт *перед minDate*
                        if let extraLeftStart = calendar.date(byAdding: .day, value: -days + 1, to: minDate) {
                            let extraLeftEnd = calendar.date(byAdding: .day, value: days - 1, to: extraLeftStart) ?? extraLeftStart
                            result.insert(makeData(from: extraLeftStart, to: extraLeftEnd), at: 0)
                        }

                        // 🔹 3. Основные шаги вперёд от start
                        var forwardStart = start
                        var lastForwardEnd: Date = end
                        while forwardStart <= maxDate {
                            let forwardEnd = calendar.date(byAdding: .day, value: days - 1, to: forwardStart) ?? forwardStart
                            result.append(makeData(from: forwardStart, to: forwardEnd))
                            lastForwardEnd = forwardEnd
                            forwardStart = calendar.date(byAdding: .day, value: days, to: forwardStart) ?? maxDate
                        }

                        // 🔹 4. Правая часть (lastForwardEnd+1 → maxDate)
                        if lastForwardEnd < maxDate {
                            let rightStart = calendar.date(byAdding: .day, value: 1, to: lastForwardEnd) ?? lastForwardEnd
                            result.append(makeData(from: rightStart, to: maxDate))
                        }

                        // 🔹 EXTRA: добавить чарт *после maxDate*
                        if let extraRightStart = calendar.date(byAdding: .day, value: days - 1, to: maxDate) {
                            let extraRightEnd = calendar.date(byAdding: .day, value: days - 1, to: extraRightStart) ?? extraRightStart
                            result.append(makeData(from: extraRightStart, to: extraRightEnd))
                        }


                    default :
                        break
                }
            })
            .store(in: &cancellables)

        return result
    }
}
