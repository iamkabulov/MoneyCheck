//
//  SelectPeriodRouter.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 03.09.2025.
//

import UIKit

protocol SelectPeriodRouterProtocol: AnyObject {
    func openCustomPeriodView(from: UIViewController, vm: SelectPeriodViewModel)
    func pop(animated: Bool)
    func dismiss(animated: Bool)
    func showError(_ title: String?, message: String?)
}


final class SelectPeriodRouter: BaseRouter {
    deinit {
        print("deinit SelectPeriodRouter")
    }
}

extension SelectPeriodRouter: SelectPeriodRouterProtocol {
    func openCustomPeriodView(from: UIViewController, vm: SelectPeriodViewModel) {
        let viewController = CustomPeriodViewController(viewModel: vm)
        
        
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
        
        from.present(viewController, animated: true)
    }
}
