//
//  SelectPeriodViewModel.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 18.08.2025.
//


import Foundation
import Combine
import UIKit

final class SelectPeriodViewModel: BaseViewModel<SelectPeriodRouterProtocol, PeriodSelectUseCaseProtocol> {

    // MARK: - Published properties
    @Published var selectedPeriod: PeriodType
    let screenTitle = "Выберите период"
    private var cancellables = Set<AnyCancellable>()
    var onOpenCustomPeriod: (() -> Void)?

    // MARK: - Initialization
    override init(
        useCase: PeriodSelectUseCaseProtocol,
        router: SelectPeriodRouterProtocol
    ) {
        self.selectedPeriod = .month
        super.init(useCase: useCase, router: router)
        self.getPeriod()
    }

    deinit {
        print("Select Period ViewModel deinit")
    }

    func getPeriod() {
        useCase.getPeriod()
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
        useCase
            .savePeriod(period: period)
            .sink { completion in
                switch completion {
                    case .finished: break
                    case .failure(_):
                        print("Error")
                }
            } receiveValue: { _ in
            }.store(in: &cancellables)
        router.dismiss(animated: true)
    }

    func customPeriodChose(_ vc: UIViewController) {
        router.openCustomPeriodView(from: vc, vm: self)
    }

    func saveCustomPeriod(_ vc: UIViewController, _ period: PeriodType) {
        self.selectedPeriod = period
        vc.dismiss(animated: true)
    }
}
