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

// MARK: - Protocols
protocol TransferRouting: AnyObject {
    func presentTransferBottomSheet(type: TransferType,
                                    delegate: TransferBottomSheetDelegate)
    func closeTransferBottomSheet()
}

protocol AddItemRouting: AnyObject {
    func showAddNewItem(type: ItemType)
}

protocol TransactionsRouting: AnyObject {
    func showTransactions(for entity: TransactionItem)
}

protocol SelectPeriodRouting: AnyObject {
    func showSelectPeriod()
    func closeSelectPeriod()
}

// MARK: - Реализация роутера
final class MainRouter {

    weak var viewController: UIViewController?
    private let financeUseCase: FinanceUseCase

    init(financeUseCase: FinanceUseCase) {
        self.financeUseCase = financeUseCase
    }
}

// MARK: - TransferRouting
extension MainRouter: TransferRouting {
    func presentTransferBottomSheet(type: TransferType,
                                    delegate: TransferBottomSheetDelegate) {
        let bottomSheetVC = TransferBottomSheetViewController(transferType: type)
        bottomSheetVC.delegate = delegate
        bottomSheetVC.modalPresentationStyle = .pageSheet

        if let sheet = bottomSheetVC.sheetPresentationController {
            sheet.detents = [ .custom { _ in
                return 160
            }]
            sheet.prefersGrabberVisible = true
        }

        self.viewController?.present(bottomSheetVC, animated: true)
    }

    func closeTransferBottomSheet() {
        self.viewController?.dismiss(animated: true)
    }
}

// MARK: - AddItemRouting
extension MainRouter: AddItemRouting {

    func showAddNewItem(type: ItemType) {
        let viewModel = AddItemViewModel(type: type, financeUseCase: financeUseCase)
        let addVC = AddItemViewController(viewModel: viewModel)
        self.viewController?.navigationController?.pushViewController(addVC, animated: true)
    }
}

// MARK: - TransactionsRouting
extension MainRouter: TransactionsRouting {
    func showTransactions(for entity: TransactionItem) {
        let viewModel = TransactionsViewModel(
            financeUseCase: financeUseCase,
            itemId: entity.id,
            itemType: entity.type
        )
        let transactionsVC = TransactionsViewController(viewModel: viewModel)
        self.viewController?.navigationController?.pushViewController(transactionsVC, animated: true)
    }
}

// MARK: - SelectPeriodRouting
extension MainRouter: SelectPeriodRouting {
    func showSelectPeriod() {
        let viewModel = SelectPeriodViewModel(financeUseCase: financeUseCase)
        let selectPeriodVC = SelectPeriodViewController(
            viewModel: viewModel,
            router: self
        )
        self.viewController?.navigationController?.pushViewController(selectPeriodVC, animated: true)
    }

    func closeSelectPeriod() {
        self.viewController?.navigationController?.popViewController(animated: true)
    }
}
