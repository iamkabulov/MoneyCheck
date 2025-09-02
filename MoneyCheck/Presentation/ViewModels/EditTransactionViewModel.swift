//
//  EditTransactionViewModel.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 26.08.2025.
//

import Foundation
import Combine

enum TransactionItem {
    case income(IncomeModel)
    case wallet(WalletModel)
    case category(CategoryModel)

    var id: UUID {
        switch self {
        case .income(let model): return model.id
        case .wallet(let model): return model.id
        case .category(let model): return model.id
        }
    }

    var type: ItemType {
        switch self {
            case .income(let model): return model.type
            case .wallet(let model): return model.type
            case .category(let model): return model.type
        }
    }
}

final class EditTransactionViewModel {
    @Published var transaction: TransactionModel
    private let router: EditTransactionRouting
    private let financeUseCase: FinanceUseCase
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init(
        transaction: TransactionModel,
        financeUseCase: FinanceUseCase,
        router: EditTransactionRouting
    ) {
        self.transaction = transaction
        self.financeUseCase = financeUseCase
        self.router = router
    }

    func saveTransaction(_ value: String?, date: Date?, comment: String?) {
        guard let amountText = value,
              let amount = Double(amountText.replacingOccurrences(of: ",", with: ".")),
              amount > 0
        else {
            return
        }

        let updatedTransaction = TransactionModel(
            id: transaction.id,
            date: date ?? transaction.date,
            amount: amount,
            type: transaction.type,
            sourceId: transaction.sourceId,
            sourceName: transaction.sourceName,
            sourceIcon: transaction.sourceIcon,
            sourceColor: transaction.sourceColor,
            destinationId: transaction.destinationId,
            destinationName: transaction.destinationName,
            destinationIcon: transaction.destinationIcon,
            destinationColor: transaction.destinationColor,
            comment: comment
        )

        financeUseCase.updateTransaction(updatedTransaction)
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error): print("Error updating transaction: \(error)")
                }
            } receiveValue: { [weak self] _ in
                self?.router.closeEditTransaction()
            }
            .store(in: &cancellables)
    }

    func deleteTransaction() {
        financeUseCase.deleteTransaction(by: transaction.id)
            .sink { completion in
                switch completion {
                    case .finished: break
                    case .failure(let error): print("Error deleting transaction: \(error)")
                }
            } receiveValue: { [weak self] _ in
                self?.router.closeEditTransaction()
            }
            .store(in: &cancellables)
    }
}
