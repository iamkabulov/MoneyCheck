import CoreData
import Foundation

final class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MoneyCheck")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let error = error as NSError
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    // MARK: - Wallet Methods
    func createWallet(name: String, type: String, balance: Double, icon: String) -> Wallet {
        let wallet = Wallet(context: context)
        wallet.id = UUID()
        wallet.name = name
        wallet.type = type
        wallet.balance = balance
        wallet.icon = icon
        saveContext()
        return wallet
    }
    
    func fetchWallets() -> [Wallet] {
        let request: NSFetchRequest<Wallet> = Wallet.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching wallets: \(error)")
            return []
        }
    }
    
    func updateWallet(_ wallet: Wallet) {
        saveContext()
    }
    
    func deleteWallet(_ wallet: Wallet) {
        context.delete(wallet)
        saveContext()
    }
    
    // MARK: - Category Methods
    func createCategory(name: String, type: String, amount: Double, icon: String, color: String) -> Category {
        let category = Category(context: context)
        category.id = UUID()
        category.name = name
        category.type = type
        category.amount = amount
        category.icon = icon
        category.color = color
        saveContext()
        return category
    }
    
    func fetchCategories() -> [Category] {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching categories: \(error)")
            return []
        }
    }
    
    func updateCategory(_ category: Category) {
        saveContext()
    }
    
    func deleteCategory(_ category: Category) {
        context.delete(category)
        saveContext()
    }
    
    // MARK: - Mock Data Initialization
    func initializeMockDataIfNeeded() {
        let wallets = fetchWallets()
        let categories = fetchCategories()
        
        if wallets.isEmpty {
            // Создаем мок кошельки
            let mockWallets = WalletModel.mockData
            for wallet in mockWallets {
                createWallet(
                    name: wallet.name,
                    type: wallet.type.rawValue,
                    balance: wallet.balance,
                    icon: wallet.icon
                )
            }
        }
        
        if categories.isEmpty {
            // Создаем мок категории
            let mockCategories = CategoryModel.mockExpenses
            for category in mockCategories {
                createCategory(
                    name: category.name,
                    type: category.type.rawValue,
                    amount: category.amount,
                    icon: category.icon,
                    color: category.color
                )
            }
        }
    }
} 
