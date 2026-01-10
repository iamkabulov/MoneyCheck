//
//  SettingsViewModel.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 07.01.2026.
//

import Combine
import Foundation

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
    @Published private(set) var reminder: StoredReminder?

    init(useCase: SettingsUseCaseProtocol, router: SettingsRouter) {
        super.init(useCase: useCase, router: router)
        self.bindDataChanges()
    }

    private func bindDataChanges() {
        useCase.settingsItem { settings in
            self.settingsViewModelEntity = .init(from: settings)
        }

        useCase.dataDidChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.loadData()
            }
            .store(in: &cancellables)
    }

    func loadData() {
        useCase.loadReminder { [weak self] reminder in
            DispatchQueue.main.async {
                self?.reminder = reminder
            }
        }
    }

    func didTapOnSettingsOption(option: SettingsEnum) {
        switch option {
            case .currency:
                self.router.openCurrencySelector()
            case .reminder:
                self.router.openReminderSettings()
            default:
                break
        }
//                case .termsAndConditions:
//                    presenter.didTapTermsAndConditions()
//                case .privacy:
//                    presenter.didTapPrivacy()
//                case .icon:
//                    presenter.didTapIcon()
//                case .feedback:
//                    presenter.didTapFeedback()
//                case .contactUs:
//                    presenter.didTapContactUs()
//                case .appReviews:
//                    presenter.didTapAppReviews()
//                case .deleteAccount:
//                    presenter.didTapDelete()
//                case .signOut:
//                    presenter.didTapSignOut()
//                case .promoCode:
//                    presenter.didTapPromoCode()
//                case .buySubscription:
//                    presenter.didTapBuySubscription()
//                default:
//                    break
//                }
    }
}
