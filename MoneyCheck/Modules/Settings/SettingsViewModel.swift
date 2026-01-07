//
//  SettingsViewModel.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 07.01.2026.
//

import Combine

public struct SettingsViewModelEntity {
    public let title: String
    public let options: [SettingsOptionSection]
    public let appVersion: String
    public let userId: String

    public init(from model: SettingsModel) {
        self.title = model.title
        self.options = model.options
        self.appVersion = "version: \(model.appVersion ?? "Not available")"
        self.userId = "userId: \(model.userId ?? "Not available")"
    }
}


final class SettingsViewModel: BaseViewModel<SettingsRouterProtocol, SettingsUseCaseProtocol> {
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Published properties
    @Published private(set) var settingsViewModelEntity: SettingsViewModelEntity?

    init(useCase: SettingsUseCaseProtocol, router: SettingsRouter) {
        super.init(useCase: useCase, router: router)
        self.bindDataChanges()
    }

    private func bindDataChanges() {
//        useCase.dataDidChange
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] in
//                self?.loadData()
//            }
//            .store(in: &cancellables)

        useCase.settingsItem { settings in
            self.settingsViewModelEntity = .init(from: settings)
        }
    }
}
