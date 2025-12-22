//
//  ItemUseCase.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 06.09.2025.
//

import Foundation
import Combine

protocol CreateItemUseCaseProtocol {
    func createIncome(name: String, icon: String, color: String) -> AnyPublisher<Void, Error>
    func createWallet(name: String, icon: String, color: String) -> AnyPublisher<Void, Error>
    func createCategory(name: String, icon: String, color: String) -> AnyPublisher<Void, Error>
}

protocol EditItemUseCaseProtocol {
    func getCategory(by id: UUID) -> AnyPublisher<CategoryModel, Error>
    func getIncome(by id: UUID) -> AnyPublisher<IncomeModel, Error>
    func getWallet(by id: UUID) -> AnyPublisher<WalletModel, Error>
    func deleteWallet(by id: UUID) -> AnyPublisher<Void, Error>
    func deleteIncome(by id: UUID) -> AnyPublisher<Void, Error>
    func deleteCategory(by id: UUID) -> AnyPublisher<Void, Error>
    func updateWallet(_ wallet: WalletModel) -> AnyPublisher<Void, Error>
    func updateCategory(_ category: CategoryModel) -> AnyPublisher<Void, Error>
    func updateIncome(_ income: IncomeModel) -> AnyPublisher<Void, Error>
}

protocol ItemUseCaseProtocol {
    func getWallets(period: PeriodType) -> AnyPublisher<[WalletModel], Error>
    func getCategories(period: PeriodType) -> AnyPublisher<[CategoryModel], Error>
    func getIncomes(period: PeriodType) -> AnyPublisher<[IncomeModel], Error>
    var dataDidChange: AnyPublisher<Void, Never> { get }
}

final class ItemUseCase {
    private let walletRepository: CoreDataWalletRepository
    private let categoryRepository: CoreDataCategoryRepository
    private let incomeRepository: CoreDataIncomeRepository
    private let dataChangeCenter = DataChangeCenter.shared

    init(
        walletRepository: CoreDataWalletRepository,
        categoryRepository: CoreDataCategoryRepository,
        incomeRepository: CoreDataIncomeRepository
    ) {
        self.walletRepository = walletRepository
        self.categoryRepository = categoryRepository
        self.incomeRepository = incomeRepository
    }

    deinit {
        print("--ItemUseCase deinit--------")
    }


}
extension ItemUseCase: ItemUseCaseProtocol {
    var dataDidChange: AnyPublisher<Void, Never> {
        dataChangeCenter.dataDidChange
    }

    func getWallets(period: PeriodType) -> AnyPublisher<[WalletModel], Error> {
        return walletRepository.getWallets(period: period)
    }

    func getCategories(period: PeriodType) -> AnyPublisher<[CategoryModel], Error> {
        return categoryRepository.getCategories(period: period)
    }

    func getIncomes(period: PeriodType) -> AnyPublisher<[IncomeModel], Error> {
        return incomeRepository.getIncomes(period: period)
    }
}

extension ItemUseCase: EditItemUseCaseProtocol {
    func getCategory(by id: UUID) -> AnyPublisher<CategoryModel, Error> {
        return categoryRepository.getCategory(by: id)
    }

    func getIncome(by id: UUID) -> AnyPublisher<IncomeModel, Error> {
        return incomeRepository.getIncome(by: id)
    }

    func getWallet(by id: UUID) -> AnyPublisher<WalletModel, Error> {
        return walletRepository.getWallet(by: id)
    }

    func deleteWallet(by id: UUID) -> AnyPublisher<Void, Error> {
        return walletRepository.deleteWallet(by: id)
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.dataChangeCenter.notify()
            })
            .eraseToAnyPublisher()
    }

    func deleteIncome(by id: UUID) -> AnyPublisher<Void, Error> {
        return incomeRepository.deleteIncome(by: id)
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.dataChangeCenter.notify()
            })
            .eraseToAnyPublisher()
    }

    func deleteCategory(by id: UUID) -> AnyPublisher<Void, Error> {
        return categoryRepository.deleteCategory(by: id)
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.dataChangeCenter.notify()
            })
            .eraseToAnyPublisher()
    }

    func updateWallet(_ wallet: WalletModel) -> AnyPublisher<Void, Error> {
        return walletRepository.updateWallet(wallet)
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.dataChangeCenter.notify()
            })
            .eraseToAnyPublisher()
    }

    func updateCategory(_ category: CategoryModel) -> AnyPublisher<Void, Error> {
        return categoryRepository.updateCategory(category)
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.dataChangeCenter.notify()
            })
            .eraseToAnyPublisher()
    }

    func updateIncome(_ income: IncomeModel) -> AnyPublisher<Void, Error> {
        return incomeRepository.updateIncome(income)
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.dataChangeCenter.notify()
            })
            .eraseToAnyPublisher()
    }
}

extension ItemUseCase: CreateItemUseCaseProtocol {
    func createIncome(name: String, icon: String, color: String) -> AnyPublisher<Void, Error> {
        let income = IncomeModel(
            id: UUID(),
            name: name,
            type: .income,
            amount: 0,
            icon: icon,
            color: color,
            transactions: []
        )
        return incomeRepository.addIncome(income)
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.dataChangeCenter.notify()
            })
            .eraseToAnyPublisher()
    }

    func createWallet(name: String, icon: String, color: String) -> AnyPublisher<Void, Error> {
        let wallet = WalletModel(
            id: UUID(),
            name: name,
            type: .wallet,
            amount: 0,
            icon: icon,
            color: color,
            transactions: []
        )
        return walletRepository.addWallet(wallet)
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.dataChangeCenter.notify()
            })
            .eraseToAnyPublisher()
    }

    func createCategory(name: String, icon: String, color: String) -> AnyPublisher<Void, Error> {
        let category = CategoryModel(
            id: UUID(),
            name: name,
            type: .category,
            amount: 0,
            icon: icon,
            color: color,
            transactions: []
        )
        return categoryRepository.addCategory(category)
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.dataChangeCenter.notify()
            })
            .eraseToAnyPublisher()
    }
}
