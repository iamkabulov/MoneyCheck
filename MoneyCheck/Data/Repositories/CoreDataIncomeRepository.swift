import Foundation
import Combine
import CoreData

final class CoreDataIncomeRepository: IncomeRepository {
    private let coreDataManager = CoreDataManager.shared
    
    func getIncomes() -> AnyPublisher<[IncomeModel], Error> {
        let incomes = coreDataManager.fetchIncomes()
        let incomeModels = incomes.map { income in
            IncomeModel(
                id: income.id ?? UUID(),
                name: income.name ?? "",
                amount: income.amount,
                icon: income.icon ?? "",
                color: income.color ?? ""
            )
        }
        return Just(incomeModels)
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