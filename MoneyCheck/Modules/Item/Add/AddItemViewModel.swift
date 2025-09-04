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

final class AddItemViewModel: BaseViewModel<ItemRouterProtocol>, ItemViewModelProtocol {

    let type: ItemType
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Published properties
    @Published var selectedIcon: String = ""
    @Published var selectedColor: String = ""
    @Published var name: String = ""
    
    var selectedIconPublisher: Published<String>.Publisher { $selectedIcon }
    var selectedColorPublisher: Published<String>.Publisher { $selectedColor }
    var namePublisher: Published<String>.Publisher { $name }

    // MARK: - Public properties
    var icons: [String]
    var colors: [String]
    
    // MARK: - Initialization
    init(type: ItemType, financeUseCase: FinanceUseCase, router: ItemRouterProtocol) {
        self.type = type
        self.icons = type.icons
        self.colors = type.colors
        super.init(financeUseCase: financeUseCase, router: router)
    }

    deinit {
        print("deinit AddItemViewModel")
    }

    // MARK: - Public methods
    func saveItem() {
        guard !name.isEmpty else {
            router?.showError(nil, message: "Заполните поле")
            return
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
                            case .finished:
                                self?.router?.pop(animated: true)
                            case .failure(let error):
                                self?.router?.showError(nil, message: error.localizedDescription)
                        }
                    } receiveValue: { [weak self] _ in
                        self?.router?.pop(animated: true)
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
                        case .finished:
                            self?.router?.pop(animated: true)
                        case .failure(let error):
                            self?.router?.showError(nil, message: error.localizedDescription)
                        }
                    } receiveValue: { [weak self] _ in
                        self?.router?.pop(animated: true)
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
                        case .finished:
                            self?.router?.pop(animated: true)
                        case .failure(let error):
                            self?.router?.showError(nil, message: error.localizedDescription)
                        }
                    } receiveValue: { [weak self] _ in
                        self?.router?.pop(animated: true)
                    }
                    .store(in: &cancellables)
        }
    }
} 
