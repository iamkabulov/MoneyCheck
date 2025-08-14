//
//  EditItemViewModel.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 14.08.2025.
//

import Foundation
import Combine

final class EditItemViewModel: ItemViewModelProtocol {
    var namePublisher: Published<String>.Publisher { $name }
    var selectedIconPublisher: Published<String>.Publisher { $selectedIcon }
    var selectedColorPublisher: Published<String>.Publisher { $selectedColor }

    private let financeUseCase: FinanceUseCase
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Published properties
    @Published var selectedIcon: String = ""
    @Published var selectedColor: String = ""
    @Published var name: String = ""
    let type: ItemType
    @Published var amount: Double = 0
    @Published var id: UUID
    @Published var transactions: [TransactionModel] = []
    var icons: [String]
    var colors: [String]

    // MARK: - Initialization
    init(id: UUID, type: ItemType, financeUseCase: FinanceUseCase) {
        self.id = id
        self.type = type
        self.icons = type.icons
        self.colors = type.colors
        self.financeUseCase = financeUseCase
        switch type {
            case .income:
                self.financeUseCase
                    .getIncome(by: id)
                    .sink { completion in
                        switch completion {
                            case .finished: break
                            case .failure(_): break
                        }
                    } receiveValue: { model in
                        self.name = model.name
                        self.amount = model.amount
                        self.selectedIcon = model.icon
                        self.selectedColor = model.color
                        self.transactions = model.transactions
                    }
                    .store(in: &cancellables)
            case .wallet:
                self.financeUseCase
                    .getWallet(by: id)
                    .sink { completion in
                        switch completion {
                            case .finished: break
                            case .failure(_): break
                        }
                    } receiveValue: { model in
                        self.name = model.name
                        self.amount = model.balance
                        self.selectedIcon = model.icon
                        self.selectedColor = model.color
                        self.transactions = model.transactions
                    }
                    .store(in: &cancellables)
            case .category:
                self.financeUseCase
                    .getCategory(by: id)
                    .sink { completion in
                        switch completion {
                            case .finished: break
                            case .failure(_): break
                        }
                    } receiveValue: { model in
                        self.name = model.name
                        self.amount = model.amount
                        self.selectedIcon = model.icon
                        self.selectedColor = model.color
                        self.transactions = model.transactions
                    }
                    .store(in: &cancellables)
        }
    }

    // MARK: - Public methods
    func deleteItem() -> AnyPublisher<Void, Error> {
        switch type {
            case .income:
                return financeUseCase.deleteIncome(by: self.id)
            case .wallet:
                return financeUseCase.deleteWallet(by: self.id)
            case .category:
                return financeUseCase.deleteCategory(by: self.id)
        }

    }

    func saveItem() -> AnyPublisher<Void, Error> {
        guard !name.isEmpty else {
            return Fail(error: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Заполните все поля"]))
                .eraseToAnyPublisher()
        }

        switch type {
            case .income:
                return financeUseCase
                    .updateIncome(
                        IncomeModel(
                            id: self.id,
                            name: self.name,
                            type: self.type,
                            amount: self.amount,
                            icon: self.selectedIcon,
                            color: self.selectedColor,
                            transactions: self.transactions
                        )
                    )
            case .wallet:
                return financeUseCase
                    .updateWallet(
                        WalletModel(
                            id: self.id,
                            name: self.name,
                            type: self.type,
                            balance: self.amount,
                            icon: self.selectedIcon,
                            color: self.selectedColor,
                            transactions: self.transactions
                        )
                    )
            case .category:
                return financeUseCase
                    .updateCategory(
                        CategoryModel(
                            id: self.id,
                            name: self.name,
                            type: self.type,
                            amount: self.amount,
                            icon: self.selectedIcon,
                            color: self.selectedColor,
                            transactions: self.transactions
                        )
                    )
        }
    }
}
