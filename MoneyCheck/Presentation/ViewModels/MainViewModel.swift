import Foundation
import Combine

final class MainViewModel {
    private let financeUseCase: FinanceUseCase
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Published properties
    @Published private(set) var wallets: [WalletModel] = []
    @Published private(set) var categories: [CategoryModel] = []
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
        categories.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    }
    
    init(financeUseCase: FinanceUseCase) {
        self.financeUseCase = financeUseCase
    }
    
    // MARK: - Public methods
    func loadData() {
        isLoading = true
        print("Starting data load...")
        
        Publishers.Zip(
            financeUseCase.getWallets(),
            financeUseCase.getCategories()
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            self?.isLoading = false
            if case .failure(let error) = completion {
                self?.error = error
                print("Error loading data: \(error)")
            }
        } receiveValue: { [weak self] wallets, categories in
            print("Data loaded successfully:")
            print("Wallets (\(wallets.count)): \(wallets.map { $0.name })")
            print("Categories (\(categories.count)): \(categories.map { $0.name })")
            self?.wallets = wallets
            self?.categories = categories
        }
        .store(in: &cancellables)
    }
    
    func transferMoney(from sourceWallet: WalletModel, to targetWallet: WalletModel, amount: Double) {
        guard sourceWallet.balance >= amount else {
            error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Недостаточно средств"])
            return
        }
        
        var updatedSourceWallet = sourceWallet
        var updatedTargetWallet = targetWallet
        
        updatedSourceWallet.balance -= amount
        updatedTargetWallet.balance += amount
        
        Publishers.Zip(
            financeUseCase.updateWallet(updatedSourceWallet),
            financeUseCase.updateWallet(updatedTargetWallet)
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            if case .failure(let error) = completion {
                self?.error = error
            }
        } receiveValue: { [weak self] _ in
            self?.loadData()
        }
        .store(in: &cancellables)
    }
    
    func addExpense(from wallet: WalletModel, to category: CategoryModel, amount: Double) {
        guard wallet.balance >= amount else {
            error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Недостаточно средств"])
            return
        }
        
        var updatedWallet = wallet
        var updatedCategory = category
        
        updatedWallet.balance -= amount
        updatedCategory.amount += amount
        
        Publishers.Zip(
            financeUseCase.updateWallet(updatedWallet),
            financeUseCase.updateCategory(updatedCategory)
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            if case .failure(let error) = completion {
                self?.error = error
            }
        } receiveValue: { [weak self] _ in
            self?.loadData()
        }
        .store(in: &cancellables)
    }
    
    func addIncome(to wallet: WalletModel, from category: CategoryModel, amount: Double) {
        var updatedWallet = wallet
        var updatedCategory = category
        
        updatedWallet.balance += amount
        updatedCategory.amount += amount
        
        Publishers.Zip(
            financeUseCase.updateWallet(updatedWallet),
            financeUseCase.updateCategory(updatedCategory)
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            if case .failure(let error) = completion {
                self?.error = error
            }
        } receiveValue: { [weak self] _ in
            self?.loadData()
        }
        .store(in: &cancellables)
    }
    
    func updateWallet(_ wallet: WalletModel) {
        financeUseCase.updateWallet(wallet)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error
                }
            } receiveValue: { [weak self] _ in
                self?.loadData()
            }
            .store(in: &cancellables)
    }
} 