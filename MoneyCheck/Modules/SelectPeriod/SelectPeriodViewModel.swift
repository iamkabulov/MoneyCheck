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
    let screenTitle = String(localized: "Select period")

    private let periodStore: PeriodStore
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init(
        useCase: PeriodSelectUseCaseProtocol,
        router: SelectPeriodRouterProtocol,
        periodStore: PeriodStore
    ) {
        self.periodStore = periodStore
        self.selectedPeriod = periodStore.period
        super.init(useCase: useCase, router: router)
        bind()
    }

    deinit {
        print("Select Period ViewModel deinit")
    }

    private func bind() {
        periodStore.$period
            .removeDuplicates()
            .assign(to: &$selectedPeriod)
    }


    func savePeriod(_ period: PeriodType) {
        periodStore.update(period)
        router.dismiss(animated: true)
    }

    func customPeriodChose(_ vc: UIViewController) {
        router.openCustomPeriodView(from: vc, vm: self)
    }

    func saveCustomPeriod(_ vc: UIViewController, _ period: PeriodType) {
        self.selectedPeriod = period
        vc.dismiss(animated: true)
    }

    func dismiss(_ vc: UIViewController) {
        vc.dismiss(animated: true)
    }
}
