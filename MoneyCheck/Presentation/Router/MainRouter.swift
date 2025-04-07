import UIKit

protocol MainRouter {
    func showTransferBottomSheet(for transferType: TransferType, delegate: TransferBottomSheetDelegate?)
}

final class MainRouterImpl: MainRouter {
    weak var viewController: UIViewController?
    
    init(viewController: UIViewController?) {
        self.viewController = viewController
    }
    
    func showTransferBottomSheet(for transferType: TransferType, delegate: TransferBottomSheetDelegate?) {
        let bottomSheet = TransferBottomSheetViewController(transferType: transferType)
        bottomSheet.delegate = delegate
        viewController?.present(bottomSheet, animated: true)
    }
} 