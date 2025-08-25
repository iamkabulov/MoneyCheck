import Foundation
import Combine

protocol TransactionRepository {
    func getTransactions(by id: UUID, period: PeriodType) -> AnyPublisher<[TransactionModel], Error>
    func addTransaction(_ transaction: TransactionModel) -> AnyPublisher<Void, Error>
    func updateTransaction(_ transaction: TransactionModel) -> AnyPublisher<Void, Error>
} 
