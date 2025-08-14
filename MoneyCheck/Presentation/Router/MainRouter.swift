import UIKit

enum TransactionItem {
    case income(IncomeModel)
    case wallet(WalletModel)
    case category(CategoryModel)
    
    var id: UUID {
        switch self {
        case .income(let model): return model.id
        case .wallet(let model): return model.id
        case .category(let model): return model.id
        }
    }
    
    var type: ItemType {
        switch self {
            case .income(let model): return model.type
            case .wallet(let model): return model.type
            case .category(let model): return model.type
        }
    }
}

import UIKit

// MARK: - Протоколы
protocol TransferRouting: AnyObject {
    func presentTransferBottomSheet(from viewController: UIViewController,
                                    type: TransferType,
                                    delegate: TransferBottomSheetDelegate)
}

protocol AddItemRouting: AnyObject {
    func showAddNewItem(navigationController: UINavigationController, type: ItemType)
}

protocol TransactionsRouting: AnyObject {
    func showTransactions(from viewController: UIViewController, for entity: TransactionItem)
}

typealias MainRouting = TransferRouting & AddItemRouting & TransactionsRouting

// MARK: - Реализация роутера
final class MainRouter: MainRouting {

    weak var viewController: UIViewController?
    private let financeUseCase: FinanceUseCase

    init(viewController: UIViewController? = nil, financeUseCase: FinanceUseCase) {
        self.viewController = viewController
        self.financeUseCase = financeUseCase
    }
    // MARK: TransferRouting
    func presentTransferBottomSheet(from viewController: UIViewController,
                                    type: TransferType,
                                    delegate: TransferBottomSheetDelegate) {
        let bottomSheetVC = TransferBottomSheetViewController(transferType: type)
        bottomSheetVC.delegate = delegate
        bottomSheetVC.modalPresentationStyle = .pageSheet

        if let sheet = bottomSheetVC.sheetPresentationController {
            sheet.detents = [.custom { _ in
                return 160
            }]
            sheet.prefersGrabberVisible = true
        }

        viewController.present(bottomSheetVC, animated: true)
    }

    // MARK: AddItemRouting
    func showAddNewItem(navigationController: UINavigationController, type: ItemType) {
        let viewModel = AddItemViewModel(type: type, financeUseCase: financeUseCase)
        let addVC = AddItemViewController(viewModel: viewModel)
        navigationController.pushViewController(addVC, animated: true)
    }

    // MARK: TransactionsRouting
    func showTransactions(from viewController: UIViewController, for entity: TransactionItem) {
        let viewModel = TransactionsViewModel(
            financeUseCase: financeUseCase,
            itemId: entity.id,
            itemType: entity.type
        )
        let transactionsVC = TransactionsViewController(viewModel: viewModel)
        viewController.navigationController?.pushViewController(transactionsVC, animated: true)
    }
}

