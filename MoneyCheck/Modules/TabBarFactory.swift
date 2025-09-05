//
//  TabBarFactory.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 05.09.2025.
//

import UIKit

final class TabBarFactory {

    init() { }

    // MARK: - Root
    func makeTabBarModule() -> UIViewController {
        let vc = TabBarController()
        return vc
    }
}
