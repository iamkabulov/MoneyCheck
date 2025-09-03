//
//  TransactionsFactory.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 03.09.2025.
//

final class TransactionsFactory {

    // MARK: - Dependencies (singletons)
    static let shared = TransactionsFactory()

    private init() { }

    // MARK: - Root
    func makeTransactionsViewModel(for entity: TransactionItem, period: PeriodType, router: TransactionsRouter) -> TransactionsViewModel {
        let viewModel = TransactionsViewModel(
            financeUseCase: FinanceUseCaseImpl.shared,
            itemId: entity.id,
            itemType: entity.type,
            router: router,
            period: period
        )
        return viewModel
    }
}
