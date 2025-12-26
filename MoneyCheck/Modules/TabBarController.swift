//
//  MainTabBarController.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 02.09.2025.
//


import UIKit

final class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupTabs()
    }

    private func setupAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = .clear

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance // ❗️КРИТИЧНО
    }

    private func setupTabs() {
        let mainNav = MainFactory.shared.makeMainModule()
        let analyticsNav = TransactionsAnalyticsFactory.shared.makeTransactionsAnalyticsModule()

        addModule(mainNav, title: "Главная", image: "house", selectedImage: "house.fill")
        addModule(analyticsNav, title: "Аналитика", image: "chart.bar", selectedImage: "chart.bar.fill")
        addModule(UIViewController(), title: "Кошелек", image: "cloud", selectedImage: "cloud.fill")
        addModule(UIViewController(), title: "Настройки", image: "gearshape", selectedImage: "gearshape.fill")
    }

    private func addModule(_ module: UIViewController, title: String, image: String, selectedImage: String) {
        module.tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(systemName: image),
            selectedImage: UIImage(systemName: selectedImage)
        )

        if viewControllers == nil {
            viewControllers = [module]
        } else {
            viewControllers?.append(module)
        }
    }
}
