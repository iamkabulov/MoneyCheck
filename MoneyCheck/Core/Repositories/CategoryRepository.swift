//
//  CategoryRepository.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 18.04.2025.
//
import Foundation
import Combine

protocol CategoryRepository {
    func getCategories(period: PeriodType) -> AnyPublisher<[CategoryModel], Error>
    func getCategory(by id: UUID) -> AnyPublisher<CategoryModel, Error>
    func addCategory(_ category: CategoryModel) -> AnyPublisher<Void, Error>
    func updateCategory(_ category: CategoryModel) -> AnyPublisher<Void, Error>
    func deleteCategory(_ category: CategoryModel) -> AnyPublisher<Void, Error>
    func deleteCategory(by id: UUID) -> AnyPublisher<Void, Error>
}
