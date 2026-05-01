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
    func showSettingsAlert(title: String?, message: String?, onCancel: (() -> Void)?, onSettings: (() -> Void)?)
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
    
    func showSettingsAlert(title: String?, message: String?, onCancel: (() -> Void)? = nil, onSettings: (() -> Void)? = nil) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        alertController.addAction(UIAlertAction(title: String(localized: "Cancel"), style: .cancel) { _ in
            onCancel?()
        })
        alertController.addAction(UIAlertAction(title: String(localized: "Settings"), style: .default) { _ in
            onSettings?()
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsUrl)
            }
        })
        
        self.present(alertController, animated: true)
    }

    func presentPanModal(_ viewController: UIViewController) {
        // 1. Принудительно загружаем view, чтобы сработал viewDidLoad и SnapKit
        viewController.loadViewIfNeeded()
        
        viewController.modalPresentationStyle = .pageSheet

        if let sheet = viewController.sheetPresentationController {
            sheet.detents = [
                .custom { context in
                    // 2. Обновляем разметку
                    viewController.view.setNeedsLayout()
                    viewController.view.layoutIfNeeded()
                    
                    let targetSize = CGSize(width: context.maximumDetentValue,
                                            height: UIView.layoutFittingCompressedSize.height)
                    
                    let fittingSize = viewController.view.systemLayoutSizeFitting(
                        targetSize,
                        withHorizontalFittingPriority: .required,
                        verticalFittingPriority: .fittingSizeLevel
                    )
                    
                    // 3. Если fittingSize слишком маленький (например, данные еще не пришли),
                    // можно вернуть дефолтную высоту или добавить отступ для Safe Area
                    let height = fittingSize.height
                    return height > 0 ? height : 360
                }
            ]
            sheet.prefersGrabberVisible = true
            // Позволяет шторке не закрывать весь экран, если контент маленький
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }
        
        navigationController.present(viewController, animated: true)
    }
}
