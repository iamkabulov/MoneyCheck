//
//  EditItemViewModel.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 14.08.2025.
//

import Foundation
import Combine

final class EditItemViewModel: BaseViewModel<ItemRouterProtocol, EditItemUseCaseProtocol>, ItemViewModelProtocol {
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
        useCase: EditItemUseCaseProtocol,
        router: ItemRouterProtocol
    ) {
        self.id = id
        self.type = type
        self.icons = type.icons
        self.colors = type.colors
        super.init(useCase: useCase, router: router)
        switch type {
            case .income:
                self.useCase
                    .getIncome(by: id)
                    .sink { completion in
                        switch completion {
                            case .finished: break
                            case .failure(let error):
                                self.router.showError(nil, message: error.localizedDescription)
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
                self.useCase
                    .getWallet(by: id)
                    .sink { completion in
                        switch completion {
                            case .finished: break
                            case .failure(let error):
                                router.showError(nil, message: error.localizedDescription)
                        }
                    } receiveValue: { model in
                        self.name = model.name
                        self.amount = model.amount
                        self.selectedIcon = model.icon
                        self.selectedColor = model.color
                        self.transactions = model.transactions
                    }
                    .store(in: &cancellables)
            case .category:
                self.useCase
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
                return useCase.deleteIncome(by: self.id)
                    .sink { [weak self] completion in
                        switch completion {
                            case .finished:
                                self?.router.pop(animated: true)
                            case .failure(let error):
                                self?.router.showError(nil, message: error.localizedDescription)
                        }
                    } receiveValue: { [weak self] _ in
                        self?.router.pop(animated: true)
                    }
                    .store(in: &cancellables)
            case .wallet:
                return useCase.deleteWallet(by: self.id)
                    .sink { [weak self] completion in
                        switch completion {
                            case .finished:
                                self?.router.pop(animated: true)
                            case .failure(let error):
                                self?.router.showError(nil, message: error.localizedDescription)
                        }
                    } receiveValue: { [weak self] _ in
                        self?.router.pop(animated: true)
                    }
                    .store(in: &cancellables)
            case .category:
                return useCase.deleteCategory(by: self.id)
                    .sink { [weak self] completion in
                        switch completion {
                            case .finished:
                                self?.router.pop(animated: true)
                            case .failure(let error):
                                self?.router.showError(nil, message: error.localizedDescription)
                        }
                    } receiveValue: {
                        [weak self] _ in
                        self?.router.pop(animated: true)
                    }
                    .store(in: &cancellables)
        }

    }

    func saveItem() {
        guard !name.isEmpty else {
            self.router.showError(nil, message: "Заполните поле")
            return
        }

        switch type {
            case .income:
                return useCase
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
                                self?.router.pop(animated: true)
                            case .failure(let error):
                                self?.router.showError(nil, message: error.localizedDescription)
                        }
                    } receiveValue: { [weak self] _ in
                        self?.router.pop(animated: true)
                    }
                    .store(in: &cancellables)
            case .wallet:
                return useCase
                    .updateWallet(
                        WalletModel(
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
                                self?.router.pop(animated: true)
                            case .failure(let error):
                                self?.router.showError(nil, message: error.localizedDescription)
                        }
                    } receiveValue: { [weak self] _ in
                        self?.router.pop(animated: true)
                    }
                    .store(in: &cancellables)
            case .category:
                return useCase
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
                                self?.router.pop(animated: true)
                            case .failure(let error):
                                self?.router.showError(nil, message: error.localizedDescription)
                        }
                    } receiveValue: { [weak self] _ in
                        self?.router.pop(animated: true)
                    }
                    .store(in: &cancellables)
        }
    }
}
