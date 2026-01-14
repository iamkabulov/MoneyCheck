//
//  ContactUsFactory.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 13.01.2026.
//

import UIKit
import PanModal

final class ContactUsFactory {
    static let shared = ContactUsFactory()

    private init() { }

    // MARK: - Root
    func makeContactUsModule(_ nav: UINavigationController) -> UIViewController & PanModalPresentable {
        let router = ContactUsRouter(navigationController: nav)
        let useCase = SettingsUseCase()
        let viewModel = ContactUsViewModel(useCase: useCase, router: router)
        let vc = ContactUsBottomSheetViewController(viewModel: viewModel)

        return vc
    }
}
