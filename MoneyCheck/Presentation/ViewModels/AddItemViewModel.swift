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
    func saveItem()
}

final class AddItemViewModel: ItemViewModelProtocol {

    private let financeUseCase: FinanceUseCase
    let type: ItemType
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Published properties
    @Published var selectedIcon: String = ""
    @Published var selectedColor: String = ""
    @Published var name: String = ""
    
    var selectedIconPublisher: Published<String>.Publisher { $selectedIcon }
    var selectedColorPublisher: Published<String>.Publisher { $selectedColor }
    var namePublisher: Published<String>.Publisher { $name }
    private let router: ItemRouting

    // MARK: - Public properties
    var icons: [String]
    var colors: [String]
    
    // MARK: - Initialization
    init(type: ItemType, financeUseCase: FinanceUseCase, router: ItemRouting) {
        self.type = type
        self.financeUseCase = financeUseCase
        self.router = router
        self.icons = type.icons
        self.colors = type.colors
    }
    
    // MARK: - Public methods
    func saveItem() {
        guard !name.isEmpty else {
            return router.showError(nil, message: "Заполните поле")
        }
        
        switch type {
        case .income:
                return financeUseCase
                    .createIncome(
                        name: name,
                        icon: selectedIcon,
                        color: selectedColor
                    )
                    .sink { [weak self] completion in
                        switch completion {
                            case .finished: break
                            self?.router.closeItemView()
                        case .failure(let error):
                            self?.router.showError(nil, message: error.localizedDescription)
                        }
                    } receiveValue: { [weak self] _ in
                        self?.router.closeItemView()
                    }
                    .store(in: &cancellables)
        case .wallet:
                return financeUseCase
                    .createWallet(
                        name: name,
                        icon: selectedIcon,
                        color: selectedColor
                    )
                    .sink { [weak self] completion in
                        switch completion {
                        case .finished: break
                            self?.router.closeItemView()
                        case .failure(let error):
                            self?.router.showError(nil, message: error.localizedDescription)
                        }
                    } receiveValue: { [weak self] _ in
                        self?.router.closeItemView()
                    }
                    .store(in: &cancellables)
        case .category:
                return financeUseCase
                    .createCategory(
                        name: name,
                        icon: selectedIcon,
                        color: selectedColor
                    )
                    .sink { [weak self] completion in
                        switch completion {
                        case .finished: break
                            self?.router.closeItemView() // роутинг прямо здесь
                        case .failure(let error):
                            self?.router.showError(nil, message: error.localizedDescription)
                        }
                    } receiveValue: { [weak self] _ in
                        self?.router.closeItemView()
                    }
                    .store(in: &cancellables)
        }
    }
} 
