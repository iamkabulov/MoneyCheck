import Foundation
import Combine

protocol IncomeRepository {
    func getIncomes() -> AnyPublisher<[IncomeModel], Error>
    func updateIncome(_ income: IncomeModel) -> AnyPublisher<Void, Error>
} 