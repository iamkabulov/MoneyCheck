import Foundation
import Combine

protocol ItemViewModelProtocol: AnyObject {
    var name: String { get set }
    var selectedIcon: String { get set }
    var selectedColor: String { get set }
    var namePublisher: Published<String>.Publisher { get }
    var selectedIconPublisher: Published<String>.Publisher { get }
    var selectedColorPublisher: Published<String>.Publisher { get }
    var icons: [String] { get set }
    var colors: [String] { get set }
    var type: ItemType { get }
    func saveItem() -> AnyPublisher<Void, Error>
}

final class AddItemViewModel: ItemViewModelProtocol {

    private let financeUseCase: FinanceUseCase
    let type: ItemType
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Published properties
    @Published var selectedIcon: String = ""
    @Published var selectedColor: String = ""
    var selectedIconPublisher: Published<String>.Publisher { $selectedIcon }
    var selectedColorPublisher: Published<String>.Publisher { $selectedColor }
    var namePublisher: Published<String>.Publisher { $name }
    @Published var name: String = ""
    
    // MARK: - Public properties
    var icons: [String]
    var colors: [String]
    
    // MARK: - Initialization
    init(type: ItemType, financeUseCase: FinanceUseCase) {
        self.type = type
        self.financeUseCase = financeUseCase
        self.icons = type.icons
        self.colors = type.colors
        // Установка начальных значений
        self.selectedColor = type.colors.first ?? ""
        self.selectedIcon = type.icons.first ?? ""
    }
    
    // MARK: - Public methods
    func saveItem() -> AnyPublisher<Void, Error> {
        guard !name.isEmpty else {
            return Fail(error: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Заполните все поля"]))
                .eraseToAnyPublisher()
        }
        
        switch type {
        case .income:
                return financeUseCase
                    .createIncome(
                        name: name,
                        icon: selectedIcon,
                        color: selectedColor
                    )
        case .wallet:
                return financeUseCase
                    .createWallet(
                        name: name,
                        icon: selectedIcon,
                        color: selectedColor
                    )
        case .category:
                return financeUseCase
                    .createCategory(
                        name: name,
                        icon: selectedIcon,
                        color: selectedColor
                    )
        }
    }
} 
