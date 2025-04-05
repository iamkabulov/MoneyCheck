import UIKit

protocol MainRouter {
    func showAddWallet()
    func showAddCategory()
    func showTransfer(from sourceWallet: WalletModel)
    func showExpense(from wallet: WalletModel)
    func showIncome(to wallet: WalletModel)
}

final class MainRouterImpl: MainRouter {
    weak var viewController: UIViewController?
    private let financeUseCase: FinanceUseCase
    
    init(financeUseCase: FinanceUseCase) {
        self.financeUseCase = financeUseCase
    }
    
    func showAddWallet() {
        // TODO: Implement add wallet screen
    }
    
    func showAddCategory() {
        // TODO: Implement add category screen
    }
    
    func showTransfer(from sourceWallet: WalletModel) {
        // TODO: Implement transfer screen
    }
    
    func showExpense(from wallet: WalletModel) {
        // TODO: Implement expense screen
    }
    
    func showIncome(to wallet: WalletModel) {
        // TODO: Implement income screen
    }
} 