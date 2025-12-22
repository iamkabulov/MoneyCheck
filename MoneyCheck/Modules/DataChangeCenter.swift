//
//  DataChangeCenter.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 22.12.2025.
//
import Combine

protocol DataChangeNotifying {
    var dataDidChange: AnyPublisher<Void, Never> { get }
}

final class DataChangeCenter: DataChangeNotifying {
    static let shared = DataChangeCenter()

    private let subject = PassthroughSubject<Void, Never>()

    var dataDidChange: AnyPublisher<Void, Never> {
        subject.eraseToAnyPublisher()
    }

    func notify() {
        subject.send()
    }
}
