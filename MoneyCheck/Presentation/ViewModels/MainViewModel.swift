import Foundation
import Combine

final class MainViewModel {
    let financeUseCase: FinanceUseCase
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Published properties
    @Published private(set) var wallets: [WalletModel] = []
    @Published private(set) var categories: [CategoryModel] = []
    @Published private(set) var incomes: [IncomeModel] = []
    @Published private(set) var error: Error?
    @Published private(set) var isLoading = false
    @Published private(set) var selectedPeriod: PeriodType = .month

    // MARK: - Calculated properties
    var totalBalance: Double {
        wallets.reduce(0) { $0 + $1.balance }
    }

    var totalExpenses: Double {
        categories.filter { $0.type == .category }.reduce(0) { $0 + $1.amount }
    }

    var totalIncome: Double {
        incomes.reduce(0) { $0 + $1.amount }
    }

    init(financeUseCase: FinanceUseCase) {
        self.financeUseCase = financeUseCase
    }

    // MARK: - Public methods
    func loadPeriod() {
        financeUseCase.getPeriod()
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error
                    print("Error loading data: \(error)")
                }
            } receiveValue: { period in
                self.selectedPeriod = period
                print("MainViewModel: Loaded period: \(period)")
            }
            .store(in: &cancellables)

    }

    func loadData() {
        isLoading = true
        Publishers.CombineLatest3(
            financeUseCase.getWallets(period: selectedPeriod),
            financeUseCase.getCategories(period: selectedPeriod),
            financeUseCase.getIncomes(period: selectedPeriod)
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            self?.isLoading = false
            if case .failure(let error) = completion {
                self?.error = error
                print("Error loading data: \(error)")
            }
        } receiveValue: { [weak self] wallets, categories, incomes in
            self?.wallets = wallets.map { wallet in
                let calculatedBalance = self?.calculateBalance(
                    for: wallet.id,
                    transactions: wallet.transactions
                )
                return WalletModel(
                    id: wallet.id,
                    name: wallet.name,
                    type: wallet.type,
                    balance: calculatedBalance ?? 0,
                    icon: wallet.icon,
                    color: wallet.color,
                    transactions: wallet.transactions
                )
            }
            self?.categories = categories.map { category in
                let calculatedBalance = self?.calculateBalance(
                    for: category.id,
                    transactions: category.transactions
                )
                return CategoryModel(
                    id: category.id,
                    name: category.name,
                    type: category.type,
                    amount: abs(calculatedBalance ?? 0),
                    icon: category.icon,
                    color: category.color,
                    transactions: category.transactions
                )
            }
            self?.incomes = incomes.map { income in
                let calculatedBalance = self?.calculateBalance(
                    for: income.id,
                    transactions: income.transactions
                )
                return IncomeModel(
                    id: income.id,
                    name: income.name,
                    type: income.type,
                    amount: calculatedBalance ?? 0,
                    icon: income.icon,
                    color: income.color,
                    transactions: income.transactions
                )
            }
        }
        .store(in: &cancellables)
    }

    private func transferMoney(from sourceWallet: WalletModel, to targetWallet: WalletModel, amount: Double) {

        var updatedSourceWallet = sourceWallet
        var updatedTargetWallet = targetWallet

        updatedSourceWallet.balance -= amount
        updatedTargetWallet.balance += amount


        let transaction = TransactionModel(
            amount: amount,
            type: .transfer,
            sourceId: sourceWallet.id,
            sourceName: sourceWallet.name,
            sourceIcon: sourceWallet.icon,
            sourceColor: sourceWallet.color,
            destinationId: targetWallet.id,
            destinationName: targetWallet.name,
            destinationIcon: targetWallet.icon,
            destinationColor: targetWallet.color
        )

        Publishers.Zip3(
            financeUseCase.updateWallet(updatedSourceWallet),
            financeUseCase.updateWallet(updatedTargetWallet),
            financeUseCase.addTransaction(transaction)
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            if case .failure(let error) = completion {
                print("❌ MainViewModel: Transfer failed with error: \(error)")
                self?.error = error
            }
        } receiveValue: { [weak self] _ in
            self?.loadData()
        }
        .store(in: &cancellables)
    }

    private func addExpense(from wallet: WalletModel, to category: CategoryModel, amount: Double) {

        var updatedWallet = wallet
        var updatedCategory = category

        updatedWallet.balance -= amount
        updatedCategory.amount += amount


        let transaction = TransactionModel(
            amount: amount,
            type: .expense,
            sourceId: wallet.id,
            sourceName: wallet.name,
            sourceIcon: wallet.icon,
            sourceColor: wallet.color,
            destinationId: category.id,
            destinationName: category.name,
            destinationIcon: category.icon,
            destinationColor: category.color
        )

        Publishers.Zip3(
            financeUseCase.updateWallet(updatedWallet),
            financeUseCase.updateCategory(updatedCategory),
            financeUseCase.addTransaction(transaction)
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            if case .failure(let error) = completion {
                print("❌ MainViewModel: Adding expense failed with error: \(error)")
                self?.error = error
            }
        } receiveValue: { [weak self] _ in
            self?.loadData()
        }
        .store(in: &cancellables)
    }

    private func addIncome(to wallet: WalletModel, from category: CategoryModel, amount: Double) {

        var updatedWallet = wallet
        var updatedCategory = category

        updatedWallet.balance += amount
        updatedCategory.amount += amount

        let transaction = TransactionModel(
            amount: amount,
            type: .income,
            sourceId: category.id,
            sourceName: category.name,
            sourceIcon: category.icon,
            sourceColor: category.color,
            destinationId: wallet.id,
            destinationName: wallet.name,
            destinationIcon: wallet.icon,
            destinationColor: wallet.color
        )

        Publishers.Zip3(
            financeUseCase.updateWallet(updatedWallet),
            financeUseCase.updateCategory(updatedCategory),
            financeUseCase.addTransaction(transaction)
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            if case .failure(let error) = completion {
                print("❌ MainViewModel: Adding income failed with error: \(error)")
                self?.error = error
            }
        } receiveValue: { [weak self] _ in
            self?.loadData()
        }
        .store(in: &cancellables)
    }

    private func addIncomeTransaction(from income: IncomeModel, to wallet: WalletModel, amount: Double) {

        var updatedIncome = income
        var updatedWallet = wallet

        updatedIncome.amount += amount
        updatedWallet.balance += amount

        let transaction = TransactionModel(
            amount: amount,
            type: .income,
            sourceId: income.id,
            sourceName: income.name,
            sourceIcon: income.icon,
            sourceColor: income.color,
            destinationId: wallet.id,
            destinationName: wallet.name,
            destinationIcon: wallet.icon,
            destinationColor: wallet.color
        )

        Publishers.Zip3(
            financeUseCase.updateIncome(updatedIncome),
            financeUseCase.updateWallet(updatedWallet),
            financeUseCase.addTransaction(transaction)
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            if case .failure(let error) = completion {
                print("❌ MainViewModel: Adding income transaction failed with error: \(error)")
                self?.error = error
            }
        } receiveValue: { [weak self] _ in
            self?.loadData()
        }
        .store(in: &cancellables)
    }

    // MARK: - Helper Methods
    func wallet(at indexPath: IndexPath) -> WalletModel? {
        guard indexPath.item < wallets.count else { return nil }
        return wallets[indexPath.item]
    }

    func category(at indexPath: IndexPath) -> CategoryModel? {
        guard indexPath.item < categories.count else { return nil }
        return categories[indexPath.item]
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

    func handleTransfer(type: TransferType, amount: Double) {
        switch type {
        case .income(let income, let wallet):
            addIncomeTransaction(from: income, to: wallet, amount: amount)
        case .wallet(let source, let target):
            transferMoney(from: source, to: target, amount: amount)
        case .category(let wallet, let category):
            if category.type == .category {
                addExpense(from: wallet, to: category, amount: amount)
            } else {
                addIncome(to: wallet, from: category, amount: amount)
            }
        }
    }
}
