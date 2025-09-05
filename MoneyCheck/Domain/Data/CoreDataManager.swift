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
    func createWallet(id: UUID = UUID(), name: String, type: String, balance: Double, icon: String, color: String) {
        let wallet = Wallet(context: context)
        wallet.id = id
        wallet.name = name
        wallet.type = type
        wallet.icon = icon
        wallet.color = color
        saveContext()
        return
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
    func createCategory(id: UUID = UUID(), name: String, type: String, amount: Double, icon: String, color: String) {
        let category = Category(context: context)
        category.id = id
        category.name = name
        category.type = type
        category.icon = icon
        category.color = color
        saveContext()
        return
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
    func createIncome(id: UUID = UUID(), name: String, amount: Double, icon: String, color: String) {
        let income = Income(context: context)
        income.id = id
        income.name = name
        income.icon = icon
        income.color = color
        saveContext()
        return
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
        destinationColor: String,
        comment: String?
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
        transaction.comment = comment

        saveContext()
        return transaction
    }

    func fetchTransactions(by id: UUID, period: PeriodType) -> [Transaction] {
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        switch period {
            case .custom(let from, let to):           // 00:00:00 локально для to
                let start = calendar.startOfDay(for: from)
                let end = calendar.endOfDay(for: to)
                request.predicate = NSPredicate(
                    format: "(sourceId == %@ OR destinationId == %@) AND (date >= %@ AND date < %@)",
                    id as CVarArg,
                    id as CVarArg,
                    start as CVarArg,
                    end as CVarArg
                )
            case .lastMonth:
                if let lastMonthDate = calendar.date(byAdding: .month, value: -1, to: Date()),
                   let monthInterval = calendar.dateInterval(of: .month, for: lastMonthDate) {

                    let start = calendar.startOfDay(for: monthInterval.start)
                    let end = calendar.startOfDay(for: monthInterval.end)

                    request.predicate = NSPredicate(
                        format: "(sourceId == %@ OR destinationId == %@) AND (date >= %@ AND date <= %@)",
                        id as CVarArg,
                        id as CVarArg,
                        start as CVarArg,
                        end as CVarArg
                    )
                }
            case .month:
                if let monthInterval = calendar.dateInterval(of: .month, for: Date()) {
                    let start = calendar.startOfDay(for: monthInterval.start)
                    let end = calendar.startOfDay(for: monthInterval.end)
                    request.predicate = NSPredicate(format: "(sourceId == %@ OR destinationId == %@) AND (date >= %@ AND date <= %@)",
                                                    id as CVarArg,
                                                    id as CVarArg,
                                                    start as CVarArg,
                                                    end as CVarArg)
                }
            case .week:
                if let weekInterval = calendar.dateInterval(of: .weekOfYear, for: Date()) {
                    let start = calendar.startOfDay(for: weekInterval.start)
                    let end = calendar.startOfDay(for: weekInterval.end) // начало следующей недели
                    request.predicate = NSPredicate(format: "(sourceId == %@ OR destinationId == %@) AND (date >= %@ AND date <= %@)",
                                                    id as CVarArg,
                                                    id as CVarArg,
                                                    start as CVarArg,
                                                    end as CVarArg)
                }
            case .wholeTime:
                request.predicate = NSPredicate(format: "(sourceId == %@ OR destinationId == %@)",
                                                id as CVarArg,
                                                id as CVarArg)
        }

        do {
            let transactions = try context.fetch(request)
            return transactions
        } catch {
            print("❌ CoreDataManager: Error fetching transactions: \(error)")
            return []
        }
    }

    func deleteTransaction(by id: UUID) {
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        do {
            if let transaction = try context.fetch(request).first {
                context.delete(transaction)
                try context.save()
            }
        } catch {
            print("Error deleting transaction: \(error)")
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
            _ = createCategory(name: "Продукты", type: "Расход", amount: 0, icon: "cart", color: "#CD4E50")
            _ = createCategory(name: "Транспорт", type: "Расход", amount: 0, icon: "bus", color: "#CD4E81")
            _ = createCategory(name: "Подписки", type: "Расход", amount: 0, icon: "repeat", color: "#A54ECD")
            _ = createCategory(name: "Развлечения", type: "Расход", amount: 0, icon: "gamecontroller", color: "#674ECD")
            _ = createCategory(name: "Ремонт", type: "Расход", amount: 0, icon: "hammer", color: "#4E74CD")
            _ = createCategory(name: "Здоровье", type: "Расход", amount: 0, icon: "cross.case", color: "#4EBBCD")
            _ = createCategory(name: "Фаст фуд", type: "Расход", amount: 0, icon: "fork.knife", color: "#4ECDC4")
            _ = createCategory(name: "Путешествия", type: "Расход", amount: 0, icon: "airplane", color: "#4ECD81")
            _ = createCategory(name: "Кредиты", type: "Расход", amount: 0, icon: "creditcard", color: "#8ACD4E")
            _ = createCategory(name: "Подарки", type: "Расход", amount: 0, icon: "gift", color: "#CDCD4E")
            _ = createCategory(name: "Коммунальные услуги", type: "Расход", amount: 0, icon: "spigot", color: "#CD8A4E")
            _ = createCategory(name: "Фитнес", type: "Расход", amount: 0, icon: "figure.cooldown", color: "#CD674E")
        }
        
        if incomes.isEmpty {
            _ = createIncome(name: "Доходы", amount: 0, icon: "dollarsign.circle", color: "#4CAF50")
            _ = createIncome(name: "Прибыль", amount: 0, icon: "chart.line.uptrend.xyaxis", color: "#2196F3")
        }
    }

    func getPeriod() -> PeriodType {
        let request: NSFetchRequest<Period> = Period.fetchRequest()
        do {
            let period = try context.fetch(request)
            guard let period = period.first else {
                return .month
            }
            guard let result = PeriodType.from(id: Int(period.id), from: period.start, to: period.end) else {
                return .month
            }
            return result
        } catch {
            print("Error fetching wallets: \(error)")
            return .month
        }
    }

    func savePeriod(_ value: PeriodType) {
        deleteAllPeriods()

        do {
            switch value {
                case .lastMonth:
                    let period = Period(context: context)
                    period.id = Int64(value.id)
                    try context.save()
                case .month:
                    let period = Period(context: context)
                    period.id = Int64(value.id)
                    try context.save()
                case .week:
                    let period = Period(context: context)
                    period.id = Int64(value.id)
                    try context.save()
                case .custom(let from, let to):
                    let period = Period(context: context)
                    period.id = Int64(value.id)
                    let calendar = Calendar.current
                    period.start = calendar.startOfDay(for: from)
                    period.end = calendar.endOfDay(for: to)
                    try context.save()
                case .wholeTime:
                    let period = Period(context: context)
                    period.id = Int64(value.id)
                    try context.save()
            }
        } catch {
            print("Error saving period: \(error)")
        }
    }

    private func deleteAllPeriods() {
        let request: NSFetchRequest<Period> = Period.fetchRequest()
        do {
            if let entity = try context.fetch(request).first {
                context.delete(entity)
                try context.save()
            }
        } catch {
            print("Error deleting period: \(error)")
        }
    }
}

extension Calendar {
    func endOfDay(for date: Date) -> Date {
        guard let nextDay = self.date(byAdding: .day, value: 1, to: startOfDay(for: date)) else {
            return date
        }
        guard let day = self.date(byAdding: .second, value: -1, to: nextDay) else {
            return date
        }
        return day
    }
}
