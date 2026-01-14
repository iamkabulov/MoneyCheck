//
//  ContactUsViewModel.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 14.01.2026.
//

import UIKit
import Combine

final class ContactUsViewModel: BaseViewModel<ContactUsRouterProtocol, SettingsUseCaseProtocol> {


    //    private let service: ReminderServiceProtocol
    @Published private(set) var model: [ContactModel] = [ContactModel(from: .telegram),
                                                         ContactModel(from: .whatsapp),
                                                         ContactModel(from: .email)]
    
    private var cancellables = Set<AnyCancellable>()

    override init(
        useCase: SettingsUseCaseProtocol,
        router: ContactUsRouterProtocol
    ) {
        super.init(useCase: useCase, router: router)
    }

    deinit {
        print("Deinited ContactUs")
    }

    func didTapButton(model: ContactModel) {
        switch model.type {
            case .telegram:
                break
            case .whatsapp:
                break
            case .email:
                guard let receiver = model.url?.absoluteString else { return }
                useCase.settingsItem { model in
                    self.router
                        .openEmail(
                            receiver: receiver,
                            iosVersion: model.iosVersion,
                            appVersion: model.appVersion,
                            userId: model.userId
                        )
                }
        }

    }
}



