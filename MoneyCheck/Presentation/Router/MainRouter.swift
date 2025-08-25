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
    func closeTransferBottomSheet()
}

protocol ItemRouting: AnyObject {
    func closeItemView()
    func showError(_ title: String?, message: String)
}

protocol TransactionsRouting: AnyObject {
    func closeTransactions()
    func showEditItemView(id: UUID, type: ItemType)
    func showError(_ title: String?, message: String)
}

protocol SelectPeriodRouting: AnyObject {
    func openCustomPeriodView(vm: SelectPeriodViewModel)
    func closeCustomPeriodView()
    func closeSelectPeriod()
}

// MARK: - Реализация роутера
final class MainRouter {

    weak var viewController: UIViewController?
    private let financeUseCase: FinanceUseCase

    init(financeUseCase: FinanceUseCase) {
        self.financeUseCase = financeUseCase
    }

    func showAddNewItem(type: ItemType) {
        let viewModel = AddItemViewModel(type: type, financeUseCase: financeUseCase, router: self)
        let addVC = AddItemViewController(viewModel: viewModel)
        self.viewController?.navigationController?.pushViewController(addVC, animated: true)
    }

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

    func showTransactions(for entity: TransactionItem, period: PeriodType) {
        let viewModel = TransactionsViewModel(
            financeUseCase: financeUseCase,
            itemId: entity.id,
            itemType: entity.type,
            router: self,
            period: period
        )
        let transactionsVC = TransactionsViewController(viewModel: viewModel)
        self.viewController?.navigationController?.pushViewController(transactionsVC, animated: true)
    }

    func showSelectPeriod() {
        let viewModel = SelectPeriodViewModel(
            financeUseCase: financeUseCase,
            router: self
        )
        let selectPeriodVC = SelectPeriodViewController(
            viewModel: viewModel
        )
        self.viewController?.navigationController?.pushViewController(selectPeriodVC, animated: true)
    }

    func showError(_ title: String?, message: String) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        self.viewController?.present(alertController, animated: true)
    }
}

// MARK: - TransferRouting
extension MainRouter: TransferRouting {
    func closeTransferBottomSheet() {
        self.viewController?.dismiss(animated: true)
    }
}

// MARK: - AddItemRouting
extension MainRouter: ItemRouting {
    func closeItemView() {
        self.viewController?.navigationController?.popToRootViewController(animated: true)
    }
}

// MARK: - TransactionsRouting
extension MainRouter: TransactionsRouting {
    func showEditItemView(id: UUID, type: ItemType) {
        let viewModel = EditItemViewModel(
            id: id,
            type: type,
            financeUseCase: financeUseCase,
            router: self
        )
        let addVC = AddItemViewController(viewModel: viewModel)
        self.viewController?.navigationController?.pushViewController(addVC, animated: true)
    }

    func closeTransactions() {
        self.viewController?.navigationController?.popViewController(animated: true)
    }
}

// MARK: - SelectPeriodRouting
extension MainRouter: SelectPeriodRouting {
    func openCustomPeriodView(vm: SelectPeriodViewModel) {
        let vc = CustomPeriodViewController(viewModel: vm, router: self)

        self.viewController?.navigationController?.pushViewController(vc, animated: true)
    }

    func closeCustomPeriodView() {
        self.viewController?.navigationController?.popViewController(animated: true)
    }

    func closeSelectPeriod() {
        self.viewController?.navigationController?.popViewController(animated: true)
    }
}
