//
//  AppDelegate.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 23.03.2025.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // Initialize repositories
        let walletRepository = WalletRepositoryImpl()
        let categoryRepository = CategoryRepositoryImpl()
        
        // Initialize use case
        let financeUseCase = FinanceUseCaseImpl(walletRepository: walletRepository, categoryRepository: categoryRepository)
        
        // Initialize view model
        let viewModel = MainViewModel(financeUseCase: financeUseCase)
        
        // Initialize view controller
        let viewController = MainViewController(viewModel: viewModel, router: MainRouterImpl(financeUseCase: financeUseCase))
        
        // Set view controller to router
        if let router = viewController.router as? MainRouterImpl {
            router.viewController = viewController
        }
        
        let navigationController = UINavigationController(rootViewController: viewController)
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        return true
    }
}

