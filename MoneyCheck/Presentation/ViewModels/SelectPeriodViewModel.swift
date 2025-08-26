//
//  SelectPeriodViewModel.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 18.08.2025.
//


import Foundation
import Combine

final class SelectPeriodViewModel {

    @Published var selectedPeriod: PeriodType
    private let financeUseCase: FinanceUseCase
    private let router: SelectPeriodRouting
    let screenTitle = "Выберите период"
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Published properties

    // MARK: - Initialization
    init(financeUseCase: FinanceUseCase, router: SelectPeriodRouting) {
        self.financeUseCase = financeUseCase
        self.router = router
        self.selectedPeriod = .month
        self.getPeriod()
    }

    deinit {
        print("Select Period ViewModel deinit")
    }

    func getPeriod() {
        financeUseCase.getPeriod()
            .sink { completion in
                switch completion {
                    case .finished: break
                    case .failure(_):
                        print("Error")
                }
            } receiveValue: { value in
                self.selectedPeriod = value
            }.store(in: &cancellables)
    }

    func savePeriod(_ period: PeriodType) {
        financeUseCase
            .savePeriod(period: period)
            .sink { completion in
                switch completion {
                    case .finished: break
                    case .failure(_):
                        print("Error")
                }
            } receiveValue: { _ in
            }.store(in: &cancellables)
        router.closeSelectPeriod()
    }

    func customPeriodChose() {
        router.openCustomPeriodView(vm: self)
    }

    func saveCustomPeriod(_ period: PeriodType) {
        self.selectedPeriod = period
        router.closeCustomPeriodView()
    }
}
