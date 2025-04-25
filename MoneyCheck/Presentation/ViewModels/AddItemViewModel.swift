import Foundation
import Combine

final class AddItemViewModel {
    private let financeUseCase: FinanceUseCase
    private let itemType: AddItemType
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Published properties
    @Published var selectedIcon: String?
    @Published var selectedColor: String?
    @Published var name: String = ""
    
    // MARK: - Public properties
    var title: String { itemType.title }
    var icons: [String] { itemType.icons }
    var colors: [String] { itemType.colors }
    
    // MARK: - Initialization
    init(type: AddItemType, financeUseCase: FinanceUseCase) {
        self.itemType = type
        self.financeUseCase = financeUseCase
        
        // Установка начальных значений
        self.selectedColor = type.colors.first
        self.selectedIcon = type.icons.first
    }
    
    // MARK: - Public methods
    func saveItem() -> AnyPublisher<Void, Error> {
        guard let icon = selectedIcon,
              let color = selectedColor,
              !name.isEmpty else {
            return Fail(error: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Заполните все поля"]))
                .eraseToAnyPublisher()
        }
        
        switch itemType {
        case .income:
            return financeUseCase.createIncome(name: name, icon: icon, color: color)
        case .wallet:
                return financeUseCase.createWallet(name: name, icon: icon, color: color)
        case .category:
            return financeUseCase.createCategory(name: name, icon: icon, color: color)
        }
    }
} 
