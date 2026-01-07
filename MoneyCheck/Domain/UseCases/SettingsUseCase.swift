//
//  SettingsUseCase.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 07.01.2026.
//

protocol SettingsUseCaseProtocol {
    func settingsItem(completion: @escaping (SettingsModel) -> Void)
}

final class SettingsUseCase: SettingsUseCaseProtocol {

    let settingsProvider: SettingsProvider

    init() {
        self.settingsProvider = SettingsProvider()
    }

    func settingsItem(completion: @escaping (SettingsModel) -> Void) {
        settingsProvider.settingsItem { settingsModel in
            completion(settingsModel)
        }
    }
}
