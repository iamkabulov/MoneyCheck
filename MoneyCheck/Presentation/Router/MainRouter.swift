import UIKit

// MARK: - Protocols
protocol MainRouterProtocol: AnyObject {
    var navigationController: UINavigationController { get }

    func start()
    func presentTransferBottomSheet(type: TransferType,
                                    delegate: TransferBottomSheetDelegate)
    func showTransactions(for entity: TransactionItem, period: PeriodType)
    func pop(animated: Bool)
    func showError(_ title: String?, message: String?)
}

// MARK: - Реализация роутера
final class MainRouter: BaseRouter, MainRouterProtocol {
    func start() {
        let vm = MainFactory.shared.makeMainViewModel(router: self)
        let vc = MainViewController(viewModel: vm)
        navigationController.setViewControllers([vc], animated: false)
    }

    func showAddNewItem(type: ItemType) {
        let router = AddItemRouter(navigationController: navigationController)
        router.startAddNewItem(type: type)
    }

    func showTransactions(for entity: TransactionItem, period: PeriodType) {
        let router = TransactionsRouter(navigationController: navigationController)
        router.start(for: entity, period: period)
    }

    func showSelectPeriod() {
        let router = SelectPeriodRouter(navigationController: navigationController)
        router.start()
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
