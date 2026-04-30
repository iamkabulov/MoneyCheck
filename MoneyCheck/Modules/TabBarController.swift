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
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemChromeMaterial)

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }

    private func setupTabs() {
        let mainNav = MainFactory.shared.makeMainModule()
        let analyticsNav = TransactionsAnalyticsFactory.shared.makeTransactionsAnalyticsModule()
        let settings = SettingsFactory.shared.makeSettingsModule()

        addModule(mainNav, title: String(localized: "finance"), image: "house", selectedImage: "house.fill")
        addModule(analyticsNav, title: String(localized: "analytics"), image: "chart.bar", selectedImage: "chart.bar.fill")
        addModule(UIViewController(), title: "Кошелек", image: "cloud", selectedImage: "cloud.fill")
        addModule(settings, title: "Настройки", image: "gearshape", selectedImage: "gearshape.fill")
    }

    private func addModule(_ module: UIViewController, title: String, image: String, selectedImage: String) {
        module.tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(systemName: image),
            selectedImage: UIImage(systemName: selectedImage)
        )
        module.tabBarItem.accessibilityIdentifier = "TESTID_\(title)"
        if viewControllers == nil {
            viewControllers = [module]
        } else {
            viewControllers?.append(module)
        }
    }
}
