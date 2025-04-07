import UIKit
import Combine
import SnapKit

final class MainViewController: UIViewController, UICollectionViewDelegate {
    private enum Constants {
        static let headerHeight: CGFloat = 30
        enum Section {
            static let topInset: CGFloat = 8
            static let leadingInset: CGFloat = 16
            static let trailingInset: CGFloat = 16
            static let bottomInset: CGFloat = 8
        }
    }
    // MARK: - Properties
    private let viewModel: MainViewModel
    let router: MainRouter
    private var cancellables = Set<AnyCancellable>()
    private var lastHighlightedIndexPath: IndexPath?
    private var pendingTransferWallet: WalletModel?
    
    // MARK: - UI Components
    private lazy var collectionView: UICollectionView = {
        let layout = createCompositionalLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        collectionView.dragInteractionEnabled = true
        collectionView.register(MoneyCollectionViewCell.self, forCellWithReuseIdentifier: MoneyCollectionViewCell.reuseIdentifier)
        collectionView.register(
            SectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionHeaderView.reuseIdentifier
        )
        collectionView.register(
            UICollectionReusableView.self,
            forSupplementaryViewOfKind: "background",
            withReuseIdentifier: "background"
        )
        return collectionView
    }()
    
    // MARK: - Initialization
    init(viewModel: MainViewModel, router: MainRouter) {
        self.viewModel = viewModel
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        viewModel.loadData()
    }
    
    // MARK: - Private methods
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Money Check"
        navigationController?.navigationBar.prefersLargeTitles = true
        collectionView.isScrollEnabled = false
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func setupBindings() {
        viewModel.$wallets
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$categories
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$error
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] error in
                self?.showError(error)
            }
            .store(in: &cancellables)
    }
    
    private func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            switch sectionIndex {
            case 0:
                return self?.createIncomesSection()
            case 1:
                return self?.createWalletsSection()
            case 2:
                return self?.createCategoriesSection()
            default:
                return nil
            }
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 10
        layout.configuration = config
        
        NSCollectionLayoutDecorationItem.background(elementKind: "background")
        layout.register(SectionBackgroundDecorationView.self, forDecorationViewOfKind: "background")
        
        return layout
    }
    
    private func createIncomesSection() -> NSCollectionLayoutSection {
        // Размер элемента
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(70),
            heightDimension: .absolute(90)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

        // Размер группы
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .estimated(70),
            heightDimension: .estimated(90)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        // Настройка секции
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 4
        section.contentInsets = NSDirectionalEdgeInsets(
            top: Constants.Section.topInset,
            leading: Constants.Section.leadingInset,
            bottom: Constants.Section.bottomInset,
            trailing: Constants.Section.trailingInset
        )

        // Добавляем header
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(Constants.headerHeight)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        
        // Добавляем background
        let backgroundItem = NSCollectionLayoutDecorationItem.background(elementKind: "background")
        backgroundItem.contentInsets = NSDirectionalEdgeInsets(top: Constants.headerHeight, leading: 0, bottom: 0, trailing: 0)

        section.boundarySupplementaryItems = [header]
        section.decorationItems = [backgroundItem]
        
        return section
    }
    
    private func createWalletsSection() -> NSCollectionLayoutSection {
        // Размер элемента
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(70),
            heightDimension: .absolute(90)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

        // Размер группы
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .estimated(70),
            heightDimension: .estimated(90)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        // Настройка секции
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 4
        section.contentInsets = NSDirectionalEdgeInsets(
            top: Constants.Section.topInset,
            leading: Constants.Section.leadingInset,
            bottom: Constants.Section.bottomInset,
            trailing: Constants.Section.trailingInset
        )

        // Добавляем header
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(Constants.headerHeight)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )

        // Добавляем background
        let backgroundItem = NSCollectionLayoutDecorationItem.background(elementKind: "background")
        backgroundItem.contentInsets = NSDirectionalEdgeInsets(top: Constants.headerHeight, leading: 0, bottom: 0, trailing: 0)
        
        section.boundarySupplementaryItems = [header]
        section.decorationItems = [backgroundItem]

        return section
    }
    
    private func createCategoriesSection() -> NSCollectionLayoutSection {
        // Размер элемента
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(70),
            heightDimension: .absolute(90)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

        // Размер группы
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(90)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 5)
        group.interItemSpacing = .fixed(0)
        
        // Настройка секции
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 4
        section.contentInsets = NSDirectionalEdgeInsets(
            top: Constants.Section.topInset,
            leading: Constants.Section.leadingInset,
            bottom: Constants.Section.bottomInset,
            trailing: Constants.Section.trailingInset
        )

        // Добавляем header
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(Constants.headerHeight)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )

        // Добавляем background
        let backgroundItem = NSCollectionLayoutDecorationItem.background(elementKind: "background")
        backgroundItem.contentInsets = NSDirectionalEdgeInsets(top: Constants.headerHeight, leading: 0, bottom: 0, trailing: 0)
        
        section.boundarySupplementaryItems = [header]
        section.decorationItems = [backgroundItem]

        return section
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(title: "Ошибка", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showAmountInput(sourceWallet: WalletModel, destinationIndexPath: IndexPath) {
        guard let targetWallet = viewModel.wallet(at: destinationIndexPath) else { return }
        showTransferBottomSheet(for: .wallet(sourceWallet: sourceWallet, targetWallet: targetWallet))
    }
}

// MARK: - UICollectionViewDataSource
extension MainViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3 // Incomes, Wallets, Categories
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return viewModel.incomes.count
        case 1: return viewModel.wallets.count
        case 2: return viewModel.categories.count
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MoneyCollectionViewCell.reuseIdentifier, for: indexPath) as! MoneyCollectionViewCell
        switch indexPath.section {
        case 0:
            let income = viewModel.incomes[indexPath.item]
            cell.configure(
                name: income.name,
                amount: income.amount,
                icon: income.icon,
                color: income.color
            )
        case 1:
            cell.configureForWallet(viewModel.wallets[indexPath.item])
        case 2:
            cell.configureForCategory(viewModel.categories[indexPath.item])
        default:
            break
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: SectionHeaderView.reuseIdentifier,
                for: indexPath
            ) as! SectionHeaderView
            
            switch indexPath.section {
            case 0:
                header.configure(title: "Доходы", amount: viewModel.totalIncome)
            case 1:
                header.configure(title: "Кошельки", amount: viewModel.totalBalance)
            case 2:
                header.configure(title: "Категории", amount: viewModel.totalExpenses)
            default:
                break
            }
            
            return header
        }
        return UICollectionReusableView()
    }
}

// MARK: - UICollectionViewDragDelegate
extension MainViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard let cell = collectionView.cellForItem(at: indexPath) as? MoneyCollectionViewCell,
              let iconFrame = cell.iconContainerView.superview?.convert(cell.iconContainerView.frame, to: cell),
              session.location(in: cell).y >= iconFrame.minY && 
              session.location(in: cell).y <= iconFrame.maxY else {
            return []
        }

        switch indexPath.section {
        case 0: // Доходы
            let income = viewModel.incomes[indexPath.item]
            let itemProvider = NSItemProvider()
            let dragItem = UIDragItem(itemProvider: itemProvider)
            dragItem.localObject = ("income", income)
            return [dragItem]
            
        case 1: // Кошельки
            let wallet = viewModel.wallets[indexPath.item]
            let itemProvider = NSItemProvider()
            let dragItem = UIDragItem(itemProvider: itemProvider)
            dragItem.localObject = ("wallet", wallet)
            return [dragItem]
            
        default:
            return []
        }
    }

    func collectionView(_ collectionView: UICollectionView, dropPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        guard let cell = collectionView.cellForItem(at: indexPath) as? MoneyCollectionViewCell else {
            return nil
        }
        
        let parameters = UIDragPreviewParameters()
        let iconFrame = cell.iconContainerView.superview?.convert(cell.iconContainerView.frame, to: cell) ?? .zero
        parameters.visiblePath = UIBezierPath(roundedRect: iconFrame, cornerRadius: cell.iconContainerView.layer.cornerRadius)
        return parameters
    }

    func collectionView(_ collectionView: UICollectionView, dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        guard let cell = collectionView.cellForItem(at: indexPath) as? MoneyCollectionViewCell else {
            return nil
        }
        
        let parameters = UIDragPreviewParameters()
        let iconFrame = cell.iconContainerView.superview?.convert(cell.iconContainerView.frame, to: cell) ?? .zero
        parameters.visiblePath = UIBezierPath(roundedRect: iconFrame, cornerRadius: cell.iconContainerView.layer.cornerRadius)
        return parameters
    }
}

// MARK: - UICollectionViewDropDelegate
extension MainViewController: UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        guard let destinationIndexPath = coordinator.destinationIndexPath,
              let item = coordinator.items.first else {
            return
        }
        
        guard let (sourceType, sourceObject) = item.dragItem.localObject as? (String, Any) else {
            return
        }
        
        switch (sourceType, destinationIndexPath.section) {
        case ("income", 1):
            guard let income = sourceObject as? IncomeModel,
                  let wallet = viewModel.wallet(at: destinationIndexPath) else { return }
            showTransferBottomSheet(for: .income(sourceIncome: income, targetWallet: wallet))
            
        case ("wallet", 1):
            guard let sourceWallet = sourceObject as? WalletModel,
                  let targetWallet = viewModel.wallet(at: destinationIndexPath),
                  sourceWallet.id != targetWallet.id else { return }
            showTransferBottomSheet(for: .wallet(sourceWallet: sourceWallet, targetWallet: targetWallet))
            
        case ("wallet", 2):
            guard let wallet = sourceObject as? WalletModel,
                  let category = viewModel.category(at: destinationIndexPath) else { return }
            showTransferBottomSheet(for: .category(sourceWallet: wallet, targetCategory: category))
            
        default:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        return UICollectionViewDropProposal(operation: .move)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidEnd session: UIDropSession) {
        // Убираем подсветку при завершении перетаскивания
        if let lastPath = lastHighlightedIndexPath {
            highlightCell(at: lastPath, isHighlighted: false)
            lastHighlightedIndexPath = nil
        }
    }
    
    private func highlightCell(at indexPath: IndexPath, isHighlighted: Bool) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? MoneyCollectionViewCell else { return }
        
        UIView.animate(withDuration: 0.1) {
            cell.alpha = isHighlighted ? 0.9 : 1.0
        }
    }
}

// MARK: - Helper Methods
private extension MainViewController {
    func showTransferBottomSheet(for transferType: TransferType) {
        router.showTransferBottomSheet(for: transferType, delegate: self)
    }
}

private extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK: - UICollectionViewDelegate
extension MainViewController {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //TODO: - СДЕЛАТЬ по тапу историю
    }
    
    private func showAddMoneyInput(to wallet: WalletModel) {
        let vc = UIViewController()
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        vc.modalPresentationStyle = .overFullScreen
        
        let containerView = UIView()
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 16
        
        let titleLabel = UILabel()
        titleLabel.text = "Добавить в \(wallet.name)"
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        
        let textField = UITextField()
        textField.placeholder = "Сумма"
        textField.keyboardType = .decimalPad
        textField.borderStyle = .roundedRect
        
        let buttonsStack = UIStackView()
        buttonsStack.axis = .horizontal
        buttonsStack.distribution = .fillEqually
        buttonsStack.spacing = 8
        
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Отмена", for: .normal)
        cancelButton.addAction(UIAction { _ in
            vc.dismiss(animated: true)
        }, for: .touchUpInside)
        
        let okButton = UIButton(type: .system)
        okButton.setTitle("Добавить", for: .normal)
        okButton.addAction(UIAction { [weak self] _ in
            guard let amountText = textField.text,
                  let amount = Double(amountText.replacingOccurrences(of: ",", with: ".")),
                  amount > 0 else {
                return
            }
            
            var updatedWallet = wallet
            updatedWallet.balance += amount
            self?.viewModel.updateWallet(updatedWallet)
            
            vc.dismiss(animated: true)
        }, for: .touchUpInside)
        
        buttonsStack.addArrangedSubview(cancelButton)
        buttonsStack.addArrangedSubview(okButton)
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(textField)
        containerView.addSubview(buttonsStack)
        vc.view.addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(270)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        textField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        buttonsStack.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-16)
            make.height.equalTo(44)
        }
        
        // Добавляем обработчик нажатия на фон для закрытия
        let tapGesture = UITapGestureRecognizer(target: vc, action: #selector(UIViewController.dismiss))
        vc.view.addGestureRecognizer(tapGesture)
        containerView.isUserInteractionEnabled = true
        
        present(vc, animated: true) {
            textField.becomeFirstResponder()
        }
    }
}

// MARK: - TransferBottomSheetDelegate
extension MainViewController: TransferBottomSheetDelegate {
    func transferBottomSheet(_ viewController: TransferBottomSheetViewController, didConfirmAmount amount: Double) {
        switch viewController.transferType {
        case .income(let income, let wallet):
            var updatedIncome = income
            var updatedWallet = wallet
            
            updatedIncome.amount += amount
            updatedWallet.balance += amount
            
            viewModel.updateIncome(updatedIncome)
            viewModel.updateWallet(updatedWallet)
            
        case .wallet(let source, let target):
            viewModel.transferMoney(from: source, to: target, amount: amount)
            
        case .category(let wallet, let category):
            if category.type == .expense {
                viewModel.addExpense(from: wallet, to: category, amount: amount)
            } else {
                viewModel.addIncome(to: wallet, from: category, amount: amount)
            }
        }
    }
    
    func transferBottomSheetDidCancel(_ viewController: TransferBottomSheetViewController) {
        // Очищаем состояние, если нужно
        pendingTransferWallet = nil
        lastHighlightedIndexPath = nil
    }
} 



