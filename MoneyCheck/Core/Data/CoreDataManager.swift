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
    func createWallet(name: String, type: String, balance: Double, icon: String, color: String) -> Wallet {
        let wallet = Wallet(context: context)
        wallet.id = UUID()
        wallet.name = name
        wallet.type = type
        wallet.balance = balance
        wallet.icon = icon
        wallet.color = color
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

    func fetchWallet(by id: UUID) -> Wallet? {
        let request: NSFetchRequest<Wallet> = Wallet.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1 // чтобы не грузить всё
        do {
            return try context.fetch(request).first
        } catch {
            print("Error fetching incomes: \(error)")
            return nil
        }
    }

    func updateWallet(_ wallet: Wallet) {
        saveContext()
    }
    
    func deleteWallet(_ wallet: Wallet) {
        context.delete(wallet)
        saveContext()
    }

    func deleteWallet(by id: UUID) {
        let request: NSFetchRequest<Wallet> = Wallet.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1 // возьмём только один объект

        do {
            if let wallet = try context.fetch(request).first {
                context.delete(wallet)
                try context.save()
            }
        } catch {
            print("Error deleting wallet: \(error)")
        }
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

    func fetchCategory(by id: UUID) -> Category? {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1 // чтобы не грузить всё
        do {
            return try context.fetch(request).first
        } catch {
            print("Error fetching incomes: \(error)")
            return nil
        }
    }

    func updateCategory(_ category: Category) {
        saveContext()
    }
    
    func deleteCategory(_ category: Category) {
        context.delete(category)
        saveContext()
    }

    func deleteCategory(by id: UUID) {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1 // возьмём только один объект

        do {
            if let category = try context.fetch(request).first {
                context.delete(category)
                try context.save()
            }
        } catch {
            print("Error deleting wallet: \(error)")
        }
    }

    // MARK: - Income Methods
    func createIncome(name: String, amount: Double, icon: String, color: String) -> Income {
        let income = Income(context: context)
        income.id = UUID()
        income.name = name
        income.amount = amount
        income.icon = icon
        income.color = color
        saveContext()
        return income
    }
    
    func fetchIncomes() -> [Income] {
        let request: NSFetchRequest<Income> = Income.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching incomes: \(error)")
            return []
        }
    }

    func fetchIncome(by id: UUID) -> Income? {
        let request: NSFetchRequest<Income> = Income.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1 // чтобы не грузить всё
        do {
            return try context.fetch(request).first
        } catch {
            print("Error fetching incomes: \(error)")
            return nil
        }
    }


    func updateIncome(_ income: Income) {
        saveContext()
    }

    func deleteIncome(by id: UUID) {
        let request: NSFetchRequest<Income> = Income.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1 // возьмём только один объект

        do {
            if let income = try context.fetch(request).first {
                context.delete(income)
                try context.save()
            }
        } catch {
            print("Error deleting wallet: \(error)")
        }
    }

    // MARK: - Transaction Methods
    func createTransaction(
        id: UUID,
        date: Date,
        amount: Double,
        type: String,
        sourceId: UUID,
        sourceName: String,
        sourceIcon: String,
        sourceColor: String,
        destinationId: UUID,
        destinationName: String,
        destinationIcon: String,
        destinationColor: String
    ) -> Transaction {
        
        let transaction = Transaction(context: context)
        transaction.id = id
        transaction.date = date
        transaction.amount = amount
        transaction.type = type
        transaction.sourceId = sourceId
        transaction.sourceName = sourceName
        transaction.sourceIcon = sourceIcon
        transaction.sourceColor = sourceColor
        transaction.destinationId = destinationId
        transaction.destinationName = destinationName
        transaction.destinationIcon = destinationIcon
        transaction.destinationColor = destinationColor
        
        saveContext()
        return transaction
    }
    
    func fetchTransactions() -> [Transaction] {
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            let transactions = try context.fetch(request)
            return transactions
        } catch {
            print("❌ CoreDataManager: Error fetching transactions: \(error)")
            return []
        }
    }

    func fetchTransactions(by id: UUID) -> [Transaction] {
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        request.predicate = NSPredicate(format: "sourceId == %@ OR destinationId == %@",
                                        id as CVarArg,
                                        id as CVarArg)
        do {
            let transactions = try context.fetch(request)
            return transactions
        } catch {
            print("❌ CoreDataManager: Error fetching transactions: \(error)")
            return []
        }
    }

    // MARK: - Mock Data Initialization
    func initializeMockDataIfNeeded() {
        let wallets = fetchWallets()
        let categories = fetchCategories()
        let incomes = fetchIncomes()
        
        if wallets.isEmpty {
            _ = createWallet(name: "Наличные", type: "cash", balance: 0, icon: "banknote", color: "#FFD93D")
            _ = createWallet(name: "Карта", type: "card", balance: 0, icon: "creditcard", color: "#FF8066")
            _ = createWallet(name: "Дебетовая карта", type: "card", balance: 0, icon: "creditcard", color: "#95E1D3")
            _ = createWallet(name: "Депозит", type: "deposit", balance: 0, icon: "building.columns", color: "#A8E6CF")
        }
        
        if categories.isEmpty {
            _ = createCategory(name: "Продукты", type: "Расход", amount: 0, icon: "cart", color: "#FF6B6B")
            _ = createCategory(name: "Транспорт", type: "Расход", amount: 0, icon: "bus", color: "#4ECDC4")
            _ = createCategory(name: "Фаст фуд", type: "Расход", amount: 0, icon: "fork.knife", color: "#FFD93D")
            _ = createCategory(name: "Подписки", type: "Расход", amount: 0, icon: "repeat", color: "#FF8066")
            _ = createCategory(name: "Развлечения", type: "Расход", amount: 0, icon: "gamecontroller", color: "#95E1D3")
            _ = createCategory(name: "Ремонт", type: "Расход", amount: 0, icon: "hammer", color: "#A8E6CF")
            _ = createCategory(name: "Здоровье", type: "Расход", amount: 0, icon: "heart", color: "#FF9A9E")
            _ = createCategory(name: "Путешествия", type: "Расход", amount: 0, icon: "airplane", color: "#81C784")
            _ = createCategory(name: "Кредиты", type: "Расход", amount: 0, icon: "creditcard", color: "#FFB74D")
            _ = createCategory(name: "Подарки", type: "Расход", amount: 0, icon: "gift", color: "#F48FB1")
        }
        
        if incomes.isEmpty {
            _ = createIncome(name: "Доходы", amount: 0, icon: "dollarsign.circle", color: "#4CAF50")
            _ = createIncome(name: "Прибыль", amount: 0, icon: "chart.line.uptrend.xyaxis", color: "#2196F3")
        }
    }
} 
