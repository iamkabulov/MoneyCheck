import Foundation
import Combine

struct ChartBarData {
    let startDate: Date
    let endDate: Date
    let title: String
    let total: Double
    let average: Double
    let percentage: Double?
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

    func loadTransactions(endDate: Date?) {
        let interval = self.makeDateInterval(for: self.period, basedOn: self.currentDate, endDate: endDate)

        switch period {
        case .week:
            guard let newPeriod = PeriodType.from(id: 0, from: interval.start, to: interval.end) else {
                return
            }
            self.period = newPeriod
            self.currentDate = interval.start
            getTransactions(start: interval.start, end: interval.end)

        case .month:
            guard let newPeriod = PeriodType.from(id: 2, from: interval.start, to: interval.end) else {
                return
            }
            self.period = newPeriod
            self.currentDate = interval.start
            getTransactions(start: interval.start, end: interval.end)

        case .custom:
            guard let newPeriod = PeriodType.from(id: 3, from: interval.start, to: interval.end) else {
                return
            }
            self.period = newPeriod
            self.currentDate = interval.start
            getTransactions(start: interval.start, end: interval.end)
            return // важно: не выполнять общий код ниже

        case .lastMonth, .wholeTime:
            return
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

    private func makeDateInterval(for period: PeriodType, basedOn date: Date, endDate: Date? = nil) -> (start: Date, end: Date) {
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

            case .custom(let from, let to):
                guard let endDate = endDate else { return (from, to) }
                return (currentDate, endDate)

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
            .sink(
                receiveCompletion: { completion in
                    // обработка ошибок
                },
                receiveValue: { transactions in
                    result = self.makeChartData(transactions, for: period)
                })
            .store(in: &cancellables)

        return result
    }

    private func makeChartData(_ transactions: [TransactionModel],for period: PeriodType) -> [ChartBarData] {
        var result: [ChartBarData] = []
        var previousTotal: Double = 0
        let calendar = Calendar.current
        guard let minDate = transactions.map(\.date).min(),
              let maxDate = transactions.map(\.date).max() else { return [] }

        switch period {
            case .week:
                if let start = calendar.dateInterval(of: .weekOfYear, for: minDate)?.start,
                   let end = calendar.dateInterval(of: .weekOfYear, for: maxDate)?.end {
                    var current = start
                    while current < end {
                        guard let interval = calendar.dateInterval(of: .weekOfYear, for: current) else { break }
                        let filtered = transactions.filter { $0.type == .expense && $0.date >= interval.start && $0.date < interval.end }
                        let total = filtered.reduce(0) { $0 + $1.amount }

                        let formatter = DateFormatter()
                        formatter.dateFormat = "d MMM"
                        let title = formatter.string(from: current)

                        let average = total / 7.0
                        let percentage = calculatePercentage(previousTotal: previousTotal, total: total)

                        result.append(ChartBarData(startDate: interval.start, endDate: interval.end, title: title, total: total, average: average, percentage: percentage))

                        previousTotal = total
                        current = calendar.date(byAdding: .weekOfYear, value: 1, to: current) ?? interval.end
                    }
                }

            case .month:
                if let start = calendar.dateInterval(of: .month, for: minDate)?.start,
                   let end = calendar.dateInterval(of: .month, for: maxDate)?.end {
                    var current = start
                    while current < end {
                        guard let interval = calendar.dateInterval(of: .month, for: current) else {
                            break
                        }
                        let filtered = transactions.filter { $0.type == .expense && $0.date >= interval.start && $0.date < interval.end }
                        let total = filtered.reduce(0) { $0 + $1.amount }
                        let days = calendar.dateComponents([.day], from: interval.start, to: interval.end).day ?? 1
                        let monthSymbol = calendar.shortMonthSymbols[calendar.component(.month, from: current) - 1]
                        let average = total / Double(days)

                        var percentage = calculatePercentage(previousTotal: previousTotal, total: total)
                        result.append(ChartBarData(startDate: interval.start, endDate: interval.end, title: monthSymbol, total: total, average: average, percentage: percentage))
                        previousTotal = total
                        current = calendar.date(byAdding: .month, value: 1, to: current) ?? interval.end
                    }
                }
            case .custom(let start, let end):
                // span = длина блока в днях (включительно)
                let spanDays = (calendar.dateComponents([.day], from: start, to: end).day ?? 0)
                let span = spanDays + 1

                // Нормализуем все крайние даты в начало дня — это убирает проблемы с часами/таймзонами
                let normMin = calendar.startOfDay(for: minDate)
                let normMax = calendar.startOfDay(for: maxDate)
                let normStart = calendar.startOfDay(for: start)
                // normStartEnd = конец основного интервала (inclusive)
                guard let normStartEnd = calendar.date(byAdding: .day, value: span - 1, to: normStart) else { break }

                let formatter = DateFormatter()
                formatter.dateFormat = "d MMM"

                func makeData(from: Date, to: Date) -> ChartBarData {
                    var result: ChartBarData
                    let nextTo = calendar.date(byAdding: .day, value: 1, to: to)!
                    let filtered = transactions.filter { $0.type == .expense && $0.date >= from && $0.date < nextTo }
                    let total = filtered.reduce(0) { $0 + $1.amount }
                    let average = total / Double(max(span, 1))
                    let title = formatter.string(from: from)

                    result = ChartBarData(startDate: from, endDate: to, title: title, total: total, average: average, percentage: nil)
                    previousTotal = total

                    return result
                }

                // 1) Добавляем основной выбранный период (точно once)
                result.append(makeData(from: normStart, to: normStartEnd))

                // 2) Идём влево от основного интервала: start - span, start - 2*span, ...
                var left = calendar.date(byAdding: .day, value: -span, to: normStart)!
                while left >= normMin {
                    let leftEnd = calendar.date(byAdding: .day, value: span - 1, to: left)!
                    result.insert(makeData(from: left, to: leftEnd), at: 0)
                    left = calendar.date(byAdding: .day, value: -span, to: left)!
                }
                // если после цикла normMin остался не в покрытии — добиваем хвост слева
                if let firstStart = result.first?.startDate,
                   firstStart > normMin {
                    let normMin = calendar.date(byAdding: .day, value: -span, to: firstStart)!
                    let leftTailEnd = calendar.date(byAdding: .day, value: -1, to: firstStart)!
                    result.insert(makeData(from: normMin, to: leftTailEnd), at: 0)
                }

                // 3) Идём вправо от основного интервала: end+1 .. end+span, ...
                var right = calendar.date(byAdding: .day, value: span, to: normStart)!
                var lastEnd = normStartEnd
                while right <= normMax {
                    let rightEnd = calendar.date(byAdding: .day, value: span - 1, to: right)!
                    result.append(makeData(from: right, to: rightEnd))
                    lastEnd = rightEnd
                    right = calendar.date(byAdding: .day, value: span, to: right)!
                }
                // если после цикла normMax остался не в покрытии — добиваем хвост справа
                if lastEnd < normMax {
                    let rightTailStart = calendar.date(byAdding: .day, value: 1, to: lastEnd)!
                    result.append(makeData(from: rightTailStart, to: normMax))
                }



            default :
                break
        }

        previousTotal = 0
        return result.map { value in
            let percentage = calculatePercentage(previousTotal: previousTotal, total: value.total)
            previousTotal = value.total

            return ChartBarData(
                startDate: value.startDate,
                endDate: value.endDate,
                title: value.title,
                total: value.total,
                average: value.average,
                percentage: percentage
            )
        }
    }

    private func calculatePercentage(previousTotal: Double, total: Double) -> Double? {
        if previousTotal == 0 {
            return nil
        }
        if total == 0 {
            return nil
        }
        if previousTotal > total && total > 0 {
            return -((previousTotal / total) * 100 - 100)
        } else {
            return (total / previousTotal) * 100 - 100
        }
    }
}
