//
//  EditItemViewModel.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 14.08.2025.
//

import Foundation
import Combine

final class EditItemViewModel: BaseViewModel<ItemRouterProtocol>, ItemViewModelProtocol {
    var namePublisher: Published<String>.Publisher { $name }
    var selectedIconPublisher: Published<String>.Publisher { $selectedIcon }
    var selectedColorPublisher: Published<String>.Publisher { $selectedColor }

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
    init(
        id: UUID,
        type: ItemType,
        financeUseCase: FinanceUseCase,
        router: ItemRouterProtocol
    ) {
        self.id = id
        self.type = type
        self.icons = type.icons
        self.colors = type.colors
        super.init(financeUseCase: financeUseCase, router: router)
        switch type {
            case .income:
                self.financeUseCase
                    .getIncome(by: id)
                    .sink { completion in
                        switch completion {
                            case .finished: break
                            case .failure(let error):
                                self.router?.showError(nil, message: error.localizedDescription)
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
                            case .failure(let error):
                                router.showError(nil, message: error.localizedDescription)
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

    deinit {
        print("Deinit EditItemViewModel")
    }

    // MARK: - Public methods
    func deleteItem(){
        switch type {
            case .income:
                return financeUseCase.deleteIncome(by: self.id)
                    .sink { [weak self] completion in
                        switch completion {
                            case .finished:
                                self?.router?.pop(animated: true)
                            case .failure(let error):
                                self?.router?.showError(nil, message: error.localizedDescription)
                        }
                    } receiveValue: { [weak self] _ in
                        self?.router?.pop(animated: true)
                    }
                    .store(in: &cancellables)
            case .wallet:
                return financeUseCase.deleteWallet(by: self.id)
                    .sink { [weak self] completion in
                        switch completion {
                            case .finished:
                                self?.router?.pop(animated: true)
                            case .failure(let error):
                                self?.router?.showError(nil, message: error.localizedDescription)
                        }
                    } receiveValue: { [weak self] _ in
                        self?.router?.pop(animated: true)
                    }
                    .store(in: &cancellables)
            case .category:
                return financeUseCase.deleteCategory(by: self.id)
                    .sink { [weak self] completion in
                        switch completion {
                            case .finished:
                                self?.router?.pop(animated: true)
                            case .failure(let error):
                                self?.router?.showError(nil, message: error.localizedDescription)
                        }
                    } receiveValue: {
                        [weak self] _ in
                        self?.router?.pop(animated: true)
                    }
                    .store(in: &cancellables)
        }

    }

    func saveItem() {
        guard !name.isEmpty else {
            self.router?.showError(nil, message: "Заполните поле")
            return
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
                    .sink { [weak self] completion in
                        switch completion {
                            case .finished:
                                self?.router?.pop(animated: true)
                            case .failure(let error):
                                self?.router?.showError(nil, message: error.localizedDescription)
                        }
                    } receiveValue: { [weak self] _ in
                        self?.router?.pop(animated: true)
                    }
                    .store(in: &cancellables)
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
                    .sink { [weak self] completion in
                        switch completion {
                            case .finished:
                                self?.router?.pop(animated: true)
                            case .failure(let error):
                                self?.router?.showError(nil, message: error.localizedDescription)
                        }
                    } receiveValue: { [weak self] _ in
                        self?.router?.pop(animated: true)
                    }
                    .store(in: &cancellables)
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
                    .sink { [weak self] completion in
                        switch completion {
                            case .finished:
                                self?.router?.pop(animated: true)
                            case .failure(let error):
                                self?.router?.showError(nil, message: error.localizedDescription)
                        }
                    } receiveValue: { [weak self] _ in
                        self?.router?.pop(animated: true)
                    }
                    .store(in: &cancellables)
        }
    }
}
