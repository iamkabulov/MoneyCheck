import Foundation
import Combine

protocol IncomeRepository {
    func getIncomes() -> AnyPublisher<[IncomeModel], Error>
    func updateIncome(_ income: IncomeModel) -> AnyPublisher<Void, Error>
    func addIncome(_ income: IncomeModel) -> AnyPublisher<Void, Error>
    func getIncome(by id: UUID) -> AnyPublisher<IncomeModel, Error>
}
