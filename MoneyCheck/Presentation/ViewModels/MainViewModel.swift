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
    
    // MARK: - Calculated properties
    var totalBalance: Double {
        wallets.reduce(0) { $0 + $1.balance }
    }
    
    var totalExpenses: Double {
        categories.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    }
    
    var totalIncome: Double {
        incomes.reduce(0) { $0 + $1.amount }
    }
    
    init(financeUseCase: FinanceUseCase) {
        self.financeUseCase = financeUseCase
    }
    
    // MARK: - Public methods
    func loadData() {
        isLoading = true
        
        Publishers.CombineLatest3(
            financeUseCase.getWallets(),
            financeUseCase.getCategories(),
            financeUseCase.getIncomes()
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            self?.isLoading = false
            if case .failure(let error) = completion {
                self?.error = error
                print("Error loading data: \(error)")
            }
        } receiveValue: { [weak self] wallets, categories, incomes in
            self?.wallets = wallets
            self?.categories = categories
            self?.incomes = incomes
        }
        .store(in: &cancellables)
    }
    
    func transferMoney(from sourceWallet: WalletModel, to targetWallet: WalletModel, amount: Double) {

        let transaction = TransactionModel(
            amount: amount,
            type: .transfer,
            sourceId: sourceWallet.id,
            sourceName: sourceWallet.name,
            sourceIcon: sourceWallet.icon,
            sourceColor: "#007AFF",
            destinationId: targetWallet.id,
            destinationName: targetWallet.name,
            destinationIcon: targetWallet.icon,
            destinationColor: "#007AFF"
        )

        financeUseCase.addTransaction(transaction)
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
    
    func addExpense(from wallet: WalletModel, to category: CategoryModel, amount: Double) {

        let transaction = TransactionModel(
            amount: amount,
            type: .expense,
            sourceId: wallet.id,
            sourceName: wallet.name,
            sourceIcon: wallet.icon,
            sourceColor: "#007AFF",
            destinationId: category.id,
            destinationName: category.name,
            destinationIcon: category.icon,
            destinationColor: category.color
        )

        financeUseCase.addTransaction(transaction)
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
    
    func addIncome(to wallet: WalletModel, from category: CategoryModel, amount: Double) {
        
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
            destinationColor: "#007AFF"
        )

        financeUseCase.addTransaction(transaction)
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
    
    func addIncomeTransaction(from income: IncomeModel, to wallet: WalletModel, amount: Double) {
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
            destinationColor: "#007AFF"
        )

        financeUseCase.addTransaction(transaction)
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
} 
