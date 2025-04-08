import Foundation
import Combine

class TransactionsViewModel {
    private let financeUseCase: FinanceUseCase
    private let itemId: UUID
    @Published private(set) var transactions: [TransactionModel] = []
    private var cancellables = Set<AnyCancellable>()
    
    init(financeUseCase: FinanceUseCase, itemId: UUID) {
        self.financeUseCase = financeUseCase
        self.itemId = itemId
        loadTransactions()
    }
    
    private func loadTransactions() {
        financeUseCase.getTransactions()
            .map { transactions -> [TransactionModel] in
                let filtered = transactions.filter { transaction in
                    let isSource = transaction.sourceId == self.itemId
                    let isDestination = transaction.destinationId == self.itemId
                    return isSource || isDestination
                }
                return filtered
            }
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error): break
                    //TODO:
                }
            } receiveValue: { [weak self] transactions in
                self?.transactions = transactions
            }
            .store(in: &cancellables)
    }
} 
