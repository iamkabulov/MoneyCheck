//
//  SelectPeriodViewModel.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 18.08.2025.
//


import Foundation
import Combine

final class SelectPeriodViewModel: BaseViewModel<SelectPeriodRouterProtocol> {

    // MARK: - Published properties
    @Published var selectedPeriod: PeriodType
    let screenTitle = "Выберите период"
    private var cancellables = Set<AnyCancellable>()


    // MARK: - Initialization
    override init(financeUseCase: FinanceUseCase, router: SelectPeriodRouterProtocol) {
        self.selectedPeriod = .month
        super.init(financeUseCase: financeUseCase, router: router)
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
        router?.pop(animated: true)
    }

    func customPeriodChose() {
        router?.openCustomPeriodView(vm: self)
    }

    func saveCustomPeriod(_ period: PeriodType) {
        self.selectedPeriod = period
        router?.pop(animated: true)
    }
}
