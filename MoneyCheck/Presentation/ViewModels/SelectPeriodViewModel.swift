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
    let screenTitle = "Выберите период"
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Published properties

    // MARK: - Initialization
    init(financeUseCase: FinanceUseCase) {
        self.financeUseCase = financeUseCase
        self.selectedPeriod = .month
        self.getPeriod()
    }

    private func getPeriod() {
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

    }
}

extension Calendar {
    func currentWeekInterval() -> DateInterval {
        let now = Date()
        let interval = dateInterval(of: .weekOfYear, for: now)
        return interval ?? DateInterval(start: now, end: now)
    }

    func currentMonthInterval() -> DateInterval {
        let now = Date()
        let interval = dateInterval(of: .month, for: now)
        return interval ?? DateInterval(start: now, end: now)
    }
}
