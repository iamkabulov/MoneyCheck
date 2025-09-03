//
//  MainTabBarController.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 02.09.2025.
//


import UIKit

final class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }

    private func setupTabs() {
        let mainNav = UINavigationController(rootViewController: UIViewController()) 
        mainNav.tabBarItem = UITabBarItem(
            title: "Главная",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )

        // Example: Wallet VC
        let walletVC = UIViewController() // сделаешь потом свой экран
        walletVC.tabBarItem = UITabBarItem(title: "Кошельки", image: UIImage(systemName: "cloud"), selectedImage: UIImage(systemName: "cloud.fill"))

        // Example: Settings VC
        let settingsVC = UIViewController() // и тут тоже свой экран
        settingsVC.tabBarItem = UITabBarItem(title: "Настройки", image: UIImage(systemName: "gearshape"), selectedImage: UIImage(systemName: "gearshape.fill"))


        let dashboardVC = UIViewController() // и тут тоже свой экран

        dashboardVC.tabBarItem = UITabBarItem(title: "Аналитика", image: UIImage(systemName: "chart.bar"), selectedImage: UIImage(systemName: "chart.bar.fill"))

        // Tab bar
//        let tabBarController = UITabBarController()
//        tabBarController.viewControllers = [
//            mainNav,
//            walletVC,
//            dashboardVC,
//            settingsVC
//        ]

        viewControllers = [mainNav, walletVC, dashboardVC, settingsVC]
    }
}
