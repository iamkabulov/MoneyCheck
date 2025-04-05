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
        financeUseCase.transferMoney(from: sourceWallet, to: targetWallet, amount: amount)
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
        financeUseCase.addExpense(from: wallet, to: category, amount: amount)
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
        financeUseCase.addIncome(to: wallet, from: category, amount: amount)
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