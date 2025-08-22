//
//  AppDelegate.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 23.03.2025.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // Initialize CoreData and mock data
        let coreDataManager = CoreDataManager.shared
        coreDataManager.initializeMockDataIfNeeded()
        
        // Initialize repositories
        let walletRepository = CoreDataWalletRepository()
        let categoryRepository = CoreDataCategoryRepository()
        let incomeRepository = CoreDataIncomeRepository()
        let transactionRepository = CoreDataTransactionRepository()
        let periodRepository = CoreDataPeriodRepository()

        // Initialize use case
        let financeUseCase = FinanceUseCaseImpl(
            walletRepository: walletRepository,
            categoryRepository: categoryRepository,
            incomeRepository: incomeRepository,
            transactionRepository: transactionRepository,
            periodRepository: periodRepository
        )

        // Initialize router without view controller
        let router = MainRouter(financeUseCase: financeUseCase)

        // Initialize view model
        let viewModel = MainViewModel(financeUseCase: financeUseCase, router: router)

        // Initialize view controller with router
        let viewController = MainViewController(viewModel: viewModel)
        
        // Set view controller to router
        router.viewController = viewController
        
        let navigationController = UINavigationController(rootViewController: viewController)
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        return true
    }
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MoneyCheck")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    // MARK: - Core Data Saving support
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let error = error as NSError
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
}

