import Foundation
import Combine

protocol TransactionRepository {
    func getTransactions() -> AnyPublisher<[TransactionModel], Error>
    func addTransaction(_ transaction: TransactionModel) -> AnyPublisher<Void, Error>
} 