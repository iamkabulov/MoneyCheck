//
//  PeriodStore.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 21.12.2025.
//


import Combine

final class PeriodStore {

    static let shared = PeriodStore(
        useCase: PeriodUseCase(periodRepository: CoreDataPeriodRepository())
    )
    @Published var period: PeriodType
    let useCase: PeriodSelectUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()

    private init(
        useCase: PeriodSelectUseCaseProtocol,
        defaultPeriod: PeriodType = .month
    ) {
        self.useCase = useCase
        self.period = defaultPeriod

        loadInitialPeriod()
    }

    private func loadInitialPeriod() {
        useCase.getPeriod()
            .replaceError(with: period)
            .sink { [weak self] savedPeriod in
                self?.period = savedPeriod
            }
            .store(in: &cancellables)
    }
    
    func update(_ period: PeriodType) {
        self.period = period
        
        useCase.savePeriod(period: period)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
}
