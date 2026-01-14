//
//  ContactUsRouter.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 14.01.2026.
//

import SwiftyEmail

protocol ContactUsRouterProtocol: RouterProtocol {
    func openEmail(receiver: String, iosVersion: String, appVersion: String?, userId: String?)
}


final class ContactUsRouter: BaseRouter, ContactUsRouterProtocol {

    func openEmail(receiver: String, iosVersion: String, appVersion: String?, userId: String?) {
        guard let bottomsheetVC = self.navigationController.viewControllers.last?.presentedViewController else {
            return
        }
        bottomsheetVC.dismiss(animated: true)
        SwiftyEmail.shared.sendEmail(subject: "MyMoney",
                                     body: "<br><br><br> iOS Version: \(iosVersion) <br> App Version: \(appVersion ?? "") <br> UserId: \(userId ?? "") ",
                                     recipient: receiver) { result in
            switch result {
            case .success(let emailWasSent):
                print("The viewController was presented and the email \(emailWasSent)")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
