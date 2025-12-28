//
//  TransactionsAnalyticsViewModel.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 23.12.2025.
//


import Foundation
import Combine
import SwiftUICore

final class TransactionsAnalyticsViewModel: BaseViewModel<TransactionsAnalyticsRouterProtocol, TransactionsAnalyticsUseCaseProtocol>, ObservableObject {
//    @Published var transaction: TransactionModel
    @Published var periodTitle: String = ""
    @Published var selectedCategoryIds: Set<UUID> = []
    @Published var chartDonutItems: [DonutChartItem] = []
    @Published var sections: [TransactionSection] = []
    private var transactions: [TransactionModel] = []
    let type: TransactionType = .expense
    private let calendar = Calendar.current
    var currentDate: Date {
        didSet {
//            updatePeriodTitle()
        }
    }

    @Published private(set) var wallets: [WalletModel] = []
    @Published private(set) var incomes: [IncomeModel] = []
    @Published private(set) var error: Error?
    @Published private(set) var isLoading = false
    @Published private(set) var selectedPeriod: PeriodType = .month
    private let period = PeriodStore.shared
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    override init(
        useCase: TransactionsAnalyticsUseCaseProtocol,
        router: TransactionsAnalyticsRouterProtocol
    ) {
        self.currentDate = switch period.period {
            case .month: Date()
            case .week: Date()
            case .custom(let startDate, _): startDate
            default: Date()
        }
        super.init(useCase: useCase, router: router)
        self.bindPeriod()
        self.bindDataChanges()
    }

    deinit {
        print("Deinit TransactionsAnalyticsViewModel")
    }

    func bindPeriod() {
        period.$period
            .removeDuplicates()
            .sink { [weak self] period in
                guard let self else { return }
                self.selectedPeriod = period
                self.loadDonutChartModel()
                let interval = makeDateInterval(
                    for: selectedPeriod,
                    basedOn: currentDate
                )
                self.getTransactions(start: interval.start, end: interval.end)
            }
            .store(in: &cancellables)
    }

    private func bindDataChanges() {
        useCase.dataDidChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self = self else { return }
                self.loadDonutChartModel()
                let interval = makeDateInterval(
                    for: selectedPeriod,
                    basedOn: currentDate
                )
                self.getTransactions(start: interval.start, end: interval.end)
            }
            .store(in: &cancellables)
    }

    func loadDonutChartModel() {
        isLoading = true
        useCase.getCategories(period: selectedPeriod)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error
                    print("Error loading data: \(error)")
                }
            } receiveValue: { categories in
                self.chartDonutItems = categories.map { category in
                    let calculatedBalance = self.calculateBalance(
                        for: category.id,
                        transactions: category.transactions
                    )
                    return DonutChartItem(
                        id: category.id,
                        title: category.name,
                        value: abs(calculatedBalance),
                        color: Color(hex: category.color)
                    )
                }
                //MARK: - Изначально выбранный
                self.selectedCategoryIds = Set(self.chartDonutItems.map(\.id))
            }
            .store(in: &cancellables)
    }

    private func getTransactions(start: Date, end: Date) {
        useCase.getTransactionsForInterval(type: type, start: start, end: end)
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
                    return TransactionSection(
                        date: date,
                        transactions: sectionTransactions,
                        itemId: UUID())
                }
            }
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.router.showError("Error", message: error.localizedDescription)
                }
            } receiveValue: { [weak self] sections in
                guard let self = self else { return }
                self.sections = sections
//                self.currentDate = start  ставим сюда после того, как данные пришли
            }
            .store(in: &cancellables)
    }

//    func loadTransactions(endDate: Date?) {
//        let interval = self.makeDateInterval(
//            for: self.period.period,
//            basedOn: self.currentDate,
//            endDate: endDate
//        )
//
//        switch period.period {
//        case .week:
//            guard let newPeriod = PeriodType.from(id: 0, from: interval.start, to: interval.end) else {
//                return
//            }
//            self.period.period = newPeriod
//            self.currentDate = interval.start
//            getTransactions(start: interval.start, end: interval.end)
//
//        case .month:
//            guard let newPeriod = PeriodType.from(id: 2, from: interval.start, to: interval.end) else {
//                return
//            }
//            self.period.period = newPeriod
//            self.currentDate = interval.start
//            getTransactions(start: interval.start, end: interval.end)
//
//        case .custom:
//            guard let newPeriod = PeriodType.from(id: 3, from: interval.start, to: interval.end) else {
//                return
//            }
//            self.period.period = newPeriod
//            self.currentDate = interval.start
//            getTransactions(start: interval.start, end: interval.end)
//            return // важно: не выполнять общий код ниже
//
//        case .lastMonth, .wholeTime:
//            return
//        }
//    }

    private func makeDateInterval(for period: PeriodType, basedOn date: Date, endDate: Date? = nil) -> (start: Date, end: Date) {
        switch period {
            case .week:
                //TODO: - ИСПРАВИТЬ чтобы всегда была текущая неделя, а не неделя начало месяца
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

//    func loadData() {
//        isLoading = true
//        Publishers.CombineLatest3(
//            useCase.getWallets(period: selectedPeriod),
//            useCase.getCategories(period: selectedPeriod),
//            useCase.getIncomes(period: selectedPeriod)
//        )
//        .receive(on: DispatchQueue.main)
//        .sink { [weak self] completion in
//            self?.isLoading = false
//            if case .failure(let error) = completion {
//                self?.error = error
//                print("Error loading data: \(error)")
//            }
//        } receiveValue: { [weak self] wallets, categories, incomes in
//            self?.wallets = wallets.map { wallet in
//                let calculatedBalance = self?.calculateBalance(
//                    for: wallet.id,
//                    transactions: wallet.transactions
//                )
//                return WalletModel(
//                    id: wallet.id,
//                    name: wallet.name,
//                    type: wallet.type,
//                    amount: calculatedBalance ?? 0,
//                    icon: wallet.icon,
//                    color: wallet.color,
//                    transactions: wallet.transactions
//                )
//            }
//            self?.categories = categories.map { category in
//                let calculatedBalance = self?.calculateBalance(
//                    for: category.id,
//                    transactions: category.transactions
//                )
//                return CategoryModel(
//                    id: category.id,
//                    name: category.name,
//                    type: category.type,
//                    amount: abs(calculatedBalance ?? 0),
//                    icon: category.icon,
//                    color: category.color,
//                    transactions: category.transactions
//                )
//            }
//            self?.incomes = incomes.map { income in
//                let calculatedBalance = self?.calculateBalance(
//                    for: income.id,
//                    transactions: income.transactions
//                )
//                return IncomeModel(
//                    id: income.id,
//                    name: income.name,
//                    type: income.type,
//                    amount: calculatedBalance ?? 0,
//                    icon: income.icon,
//                    color: income.color,
//                    transactions: income.transactions
//                )
//            }
//        }
//        .store(in: &cancellables)
//    }
//
    func calculateBalance(for id: UUID, transactions: [TransactionModel]) -> Double {
        transactions.reduce(0) { partial, transaction in
            switch transaction.type {
                case .income:
                    return partial + transaction.amount
                case .expense:
                    return partial - transaction.amount
                case .transfer:
                    if transaction.sourceId == id {
                        return partial - transaction.amount
                    } else if transaction.destinationId == id {
                        return partial + transaction.amount
                    }
                    return partial
            }
        }
    }

    func toggleSelection(for item: DonutChartItem) {
        if chartDonutItems.count == selectedCategoryIds.count {
            selectedCategoryIds.removeAll()
        }
        if selectedCategoryIds.contains(item.id) {
            selectedCategoryIds.remove(item.id)
        } else {
            selectedCategoryIds.insert(item.id) // 👈 append
        }
        if self.selectedCategoryIds.isEmpty {
            self.selectedCategoryIds = Set(self.chartDonutItems.map(\.id))
        }
        self.sections = includedTransactions(itemIds: self.selectedCategoryIds)
    }


    func isSelected(_ item: DonutChartItem) -> Bool {
        selectedCategoryIds.contains(item.id)
    }

    func includedTransactions(itemIds: Set<UUID>) -> [TransactionSection] {
        var transactions = [TransactionModel]()
        for itemId in itemIds {
            transactions += self.transactions.filter {
                $0.destinationId == itemId
            }
        }

        guard !transactions.isEmpty else { return [] } // если пусто — вернём []

        let grouped = Dictionary(grouping: transactions) { transaction in
            self.calendar.startOfDay(for: transaction.date)
        }
        let sortedDays = grouped.keys.sorted(by: >)

        return sortedDays.map { date in
            let sectionTransactions = grouped[date]?.sorted(by: { $0.date > $1.date }) ?? []
            return TransactionSection(
                date: date,
                transactions: sectionTransactions,
                itemId: UUID())
        }
    }

    func excludedTransactions(itemIds: Set<UUID>) -> [TransactionSection] {
        var transactions = [TransactionModel]()
        for itemId in itemIds {
            transactions += self.transactions.filter {
                $0.destinationId != itemId
            }
        }

        guard !transactions.isEmpty else { return [] } // если пусто — вернём []

        let grouped = Dictionary(grouping: transactions) { transaction in
            self.calendar.startOfDay(for: transaction.date)
        }
        let sortedDays = grouped.keys.sorted(by: >)

        return sortedDays.map { date in
            let sectionTransactions = grouped[date]?.sorted(by: { $0.date > $1.date }) ?? []
            return TransactionSection(
                date: date,
                transactions: sectionTransactions,
                itemId: UUID())
        }
    }

    func showSelectPeriod() {
        router.openSelectPeriod()
    }
}
