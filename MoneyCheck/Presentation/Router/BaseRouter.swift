//
//  RouterProtocol.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 02.09.2025.
//


import UIKit

protocol RouterProtocol: AnyObject {
    var navigationController: UINavigationController { get }
    
    func dismiss(animated: Bool)
    func pop(animated: Bool)
    func push(_ viewController: UIViewController, animated: Bool)
    func popToRoot(animated: Bool)
    func present(_ viewController: UIViewController, animated: Bool)
    func showError(_ title: String?, message: String?)
}

class BaseRouter: RouterProtocol {
    let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func present(_ viewController: UIViewController, animated: Bool) {
        navigationController.present(viewController, animated: animated)
    }

    func dismiss(animated: Bool) {
        navigationController.dismiss(animated: animated)
    }
    
    func pop(animated: Bool) {
        navigationController.popViewController(animated: animated)
    }

    func push(_ viewController: UIViewController, animated: Bool) {
        navigationController.pushViewController(viewController, animated: animated)
    }

    func popToRoot(animated: Bool) {
        navigationController.popToRootViewController(animated: animated)
    }

    func showError(_ title: String?, message: String?) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alertController, animated: true)
    }
}
