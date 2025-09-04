import UIKit

// MARK: - Protocols
protocol MainRouterProtocol: AnyObject {
    var navigationController: UINavigationController { get }
    func presentTransferBottomSheet(type: TransferType,
                                    delegate: TransferBottomSheetDelegate)
    func showTransactions(for entity: TransactionItem, period: PeriodType)
    func pop(animated: Bool)
    func showError(_ title: String?, message: String?)
}

// MARK: - Реализация роутера
final class MainRouter: BaseRouter, MainRouterProtocol {
    func showAddNewItem(type: ItemType) {
        let vc = AddItemFactory().makeAddItemModule(type: type, navigationController: navigationController)
        vc.hidesBottomBarWhenPushed = true
        self.push(vc, animated: true)
    }

    func showTransactions(for entity: TransactionItem, period: PeriodType) {
        let vc = TransactionsFactory().makeTransactionsModule(for: entity, period: period, navigationController: navigationController)
        vc.hidesBottomBarWhenPushed = true
        self.push(vc, animated: true)

    }

    func showSelectPeriod() {
        let vc = SelectPeriodFactory().makeSelectPeriodModule(navigationController: navigationController)
        vc.hidesBottomBarWhenPushed = true
        self.push(vc, animated: true)
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

        self.present(bottomSheetVC, animated: true)
    }
}
