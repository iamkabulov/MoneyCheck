import Foundation
import Combine
import CoreData

final class CoreDataIncomeRepository: IncomeRepository {

    private let coreDataManager = CoreDataManager.shared
    
    func getIncomes(period: PeriodType) -> AnyPublisher<[IncomeModel], Error> {
        let incomes = coreDataManager.fetchIncomes()
        let incomeModels = incomes.map { income in
            let transactions = coreDataManager
                .fetchTransactions(by: income.id ?? UUID())
                .map { transaction in
                    TransactionModel(
                        id: transaction.id ?? UUID(),
                        date: transaction.date ?? Date(),
                        amount: transaction.amount,
                        type: TransactionType(rawValue: transaction.type ?? "") ?? .transfer,
                        sourceId: transaction.sourceId ?? UUID(),
                        sourceName: transaction.sourceName ?? "",
                        sourceIcon: transaction.sourceIcon ?? "",
                        sourceColor: transaction.sourceColor ?? "",
                        destinationId: transaction.destinationId ?? UUID(),
                        destinationName: transaction.destinationName ?? "",
                        destinationIcon: transaction.destinationIcon ?? "",
                        destinationColor: transaction.destinationColor ?? ""
                    )
                }

            // 📌 Пересчёт баланса
//            let calculatedBalance = calculateBalance(for: income.id ?? UUID(), transactions: transactions)

            return IncomeModel(
                id: income.id ?? UUID(),
                name: income.name ?? "",
                type: ItemType(rawValue: income.type ?? "Доход") ?? .income,
                amount: income.amount,
                icon: income.icon ?? "",
                color: income.color ?? "",
                transactions: transactions.filter { transaction in
                    filterTransactionBy(transaction, period: period)
                }
            )
        }
        return Just(incomeModels)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func getIncome(by id: UUID) -> AnyPublisher<IncomeModel, Error> {
        guard let income = coreDataManager.fetchIncome(by: id) else { return Fail(error: NSError(domain: "", code: 0, userInfo: nil)).eraseToAnyPublisher()}
        let transactions = coreDataManager.fetchTransactions(by: id)
            .map { transaction in
                TransactionModel(
                    id: transaction.id ?? UUID(),
                    date: transaction.date ?? Date(),
                    amount: transaction.amount,
                    type: TransactionType(rawValue: transaction.type ?? "") ?? .transfer,
                    sourceId: transaction.sourceId ?? UUID(),
                    sourceName: transaction.sourceName ?? "",
                    sourceIcon: transaction.sourceIcon ?? "",
                    sourceColor: transaction.sourceColor ?? "",
                    destinationId: transaction.destinationId ?? UUID(),
                    destinationName: transaction.destinationName ?? "",
                    destinationIcon: transaction.destinationIcon ?? "",
                    destinationColor: transaction.destinationColor ?? ""
                )
            }

        let result = IncomeModel(
            id: income.id ?? UUID(),
            name: income.name ?? "",
            type: ItemType(rawValue: income.type ?? "Доход") ?? .income,
            amount: income.amount,
            icon: income.icon ?? "",
            color: income.color ?? "",
            transactions: transactions
        )

        return Just(result)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func updateIncome(_ income: IncomeModel) -> AnyPublisher<Void, Error> {
        let incomes = coreDataManager.fetchIncomes()
        if let existingIncome = incomes.first(where: { $0.id == income.id }) {
            existingIncome.name = income.name
            existingIncome.amount = income.amount
            existingIncome.icon = income.icon
            existingIncome.color = income.color
            coreDataManager.updateIncome(existingIncome)
        }
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func addIncome(_ income: IncomeModel) -> AnyPublisher<Void, Error> {
        let _ = coreDataManager
            .createIncome(name: income.name,
                          amount: income.amount,
                          icon: income.icon,
                          color: income.color)
        
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func deleteIncome(by id: UUID) -> AnyPublisher<Void, any Error> {
        coreDataManager.deleteIncome(by: id)
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func filterTransactionBy(_ transaction: TransactionModel, period: PeriodType) -> Bool {
        switch period {
            case .month:
                if transaction.date >= Calendar(identifier: .iso8601).currentMonthInterval().start && transaction.date <= Calendar(identifier: .iso8601).currentMonthInterval().end {
                    return true
                }
                return false
            case .week:
                if transaction.date >= Calendar(identifier: .iso8601).currentWeekInterval().start && transaction.date <= Calendar(identifier: .iso8601).currentWeekInterval().end {
                    return true
                }
                return false
        }
    }
}
