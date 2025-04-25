import UIKit

protocol MainRouter {
    func showTransferBottomSheet(for transferType: TransferType, delegate: TransferBottomSheetDelegate?)
    func showTransactions(for item: TransactionItem)
    func showAddNewItem(navigationController: UINavigationController, type: AddItemType)
}

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
    
    var title: String {
        switch self {
        case .income(let model): return model.name
        case .wallet(let model): return model.name
        case .category(let model): return model.name
        }
    }
}

final class MainRouterImpl: MainRouter {
    weak var viewController: UIViewController?
    private let financeUseCase: FinanceUseCase
    
    init(viewController: UIViewController?, financeUseCase: FinanceUseCase) {
        self.viewController = viewController
        self.financeUseCase = financeUseCase
    }
    
    func showTransferBottomSheet(for transferType: TransferType, delegate: TransferBottomSheetDelegate?) {
        let bottomSheet = TransferBottomSheetViewController(transferType: transferType)
        bottomSheet.delegate = delegate
        viewController?.present(bottomSheet, animated: true)
    }
    
    func showTransactions(for item: TransactionItem) {
        let transactionsVM = TransactionsViewModel(financeUseCase: financeUseCase, itemId: item.id)
        let transactionsVC = TransactionsViewController(viewModel: transactionsVM)
        transactionsVC.title = item.title
        viewController?.navigationController?.pushViewController(transactionsVC, animated: true)
    }

    func showAddNewItem(navigationController: UINavigationController, type: AddItemType) {
        let vc = AddItemViewController(viewModel: AddItemViewModel(type: type,financeUseCase: financeUseCase))
        navigationController.pushViewController(vc, animated: true)
    }
}
