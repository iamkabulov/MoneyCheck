import Foundation
import Combine
import CoreData

protocol IncomeRepository {
    func getIncomes(period: PeriodType) -> AnyPublisher<[IncomeModel], Error>
    func updateIncome(_ income: IncomeModel) -> AnyPublisher<Void, Error>
    func addIncome(_ income: IncomeModel) -> AnyPublisher<Void, Error>
    func getIncome(by id: UUID) -> AnyPublisher<IncomeModel, Error>
    func deleteIncome(by id: UUID) -> AnyPublisher<Void, Error>
}

final class CoreDataIncomeRepository: IncomeRepository {

    private let coreDataManager = CoreDataManager.shared
    
    func getIncomes(period: PeriodType) -> AnyPublisher<[IncomeModel], Error> {
        let incomes = coreDataManager.fetchIncomes()
        let incomeModels = incomes.map { income in
            let transactions = coreDataManager
                .fetchTransactions(by: income.id ?? UUID(), period: period)
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

            return IncomeModel(
                id: income.id ?? UUID(),
                name: income.name ?? "",
                type: ItemType(rawValue: income.type ?? "Доход") ?? .income,
                amount: income.amount,
                icon: income.icon ?? "",
                color: income.color ?? "",
                transactions: transactions
            )
        }
        return Just(incomeModels)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func getIncome(by id: UUID) -> AnyPublisher<IncomeModel, Error> {
        guard let income = coreDataManager.fetchIncome(by: id) else { return Fail(error: NSError(domain: "", code: 0, userInfo: nil)).eraseToAnyPublisher()}
        let transactions = coreDataManager.fetchTransactions(
            by: id,
            period: .week
        )
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
}
