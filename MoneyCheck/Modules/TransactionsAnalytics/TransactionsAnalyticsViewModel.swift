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
    @Published var selectedCategoryIds: Set<UUID> = []
    @Published var chartDonutItems: [DonutChartItem] = []

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
        super.init(useCase: useCase, router: router)
        self.bindPeriod()
        self.bindDataChanges()
    }

    deinit {
        print("Deinit TransactionsAnalyticsViewModel")
    }

    private func bindPeriod() {
        period.$period
            .removeDuplicates()
            .sink { [weak self] period in
                guard let self else { return }
                self.selectedPeriod = period
                self.loadDonutChartModel()
            }
            .store(in: &cancellables)
    }

    private func bindDataChanges() {
        useCase.dataDidChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.loadDonutChartModel()
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
                if self.selectedCategoryIds.isEmpty {
                    self.selectedCategoryIds = Set(self.chartDonutItems.map(\.id))
                }
            }
            .store(in: &cancellables)

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
    }


    func isSelected(_ item: DonutChartItem) -> Bool {
        selectedCategoryIds.contains(item.id)
    }
}
