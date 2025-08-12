import Foundation
import Combine
import CoreData

final class CoreDataIncomeRepository: IncomeRepository {
    private let coreDataManager = CoreDataManager.shared
    
    func getIncomes() -> AnyPublisher<[IncomeModel], Error> {
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
            let calculatedBalance = calculateBalance(for: income.id ?? UUID(), transactions: transactions)

            return IncomeModel(
                id: income.id ?? UUID(),
                name: income.name ?? "",
                amount: calculatedBalance,
                icon: income.icon ?? "",
                color: income.color ?? "",
                transactions: transactions
            )
        }
        return Just(incomeModels)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    private func calculateBalance(for incomeId: UUID, transactions: [TransactionModel]) -> Double {
        transactions.reduce(0) { partial, transaction in
            switch transaction.type {
            case .income:
                return partial + transaction.amount
            case .expense:
                return partial - transaction.amount
            case .transfer:
                if transaction.sourceId == incomeId {
                    return partial - transaction.amount
                } else if transaction.destinationId == incomeId {
                    return partial + transaction.amount
                }
                return partial
            }
        }
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
        let newIncome = Income(context: coreDataManager.context)
        newIncome.id = income.id
        newIncome.name = income.name
        newIncome.amount = income.amount
        newIncome.icon = income.icon
        newIncome.color = income.color
        coreDataManager.saveContext()
        
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
} 
