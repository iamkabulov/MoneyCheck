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
    private var cancellables = Set<AnyCancellable>()
    private var lastHighlightedIndexPath: IndexPath?
    private var pendingTransferWallet: WalletModel?
    private let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)

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

    private let periodButton = UIBarButtonItem()


    // MARK: - Initialization
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        viewModel.loadPeriod()
        viewModel.loadData()
        
        periodButton.title = switch viewModel.selectedPeriod {
            case .month: Date().monthName
            case .week: "Неделя"
            case .custom(let from, let to): "\(from.periodName)-\(to.periodName)"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        viewModel.loadData()
    }

    // MARK: - Private methods
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Финансы"
//        navigationController?.navigationBar.prefersLargeTitles = true
//        navigationItem.largeTitleDisplayMode = .automatic
//        collectionView.isScrollEnabled = false
        collectionView.showsVerticalScrollIndicator = false
        view.addSubview(collectionView)

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.bottom.equalToSuperview()
        }

        periodButton.title = viewModel.selectedPeriod.displayTitle
        periodButton.target = self
        periodButton.action = #selector(handlePeriodButtonTapped)
        self.navigationItem.rightBarButtonItem = periodButton
        self.navigationItem.rightBarButtonItem?.tintColor = .label
    }

    @objc private func handlePeriodButtonTapped() {
        viewModel.showSelectPeriod()
    }

    private func setupBindings() {
        viewModel.$selectedPeriod
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
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
            heightDimension: .absolute(95)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
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
        case 0: return viewModel.incomes.count + 1
        case 1: return viewModel.wallets.count + 1
        case 2: return viewModel.categories.count + 1
        default: return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MoneyCollectionViewCell.reuseIdentifier, for: indexPath) as! MoneyCollectionViewCell

        switch indexPath.section {
        case 0:
            if indexPath.item == viewModel.incomes.count {
                cell.configure(
                    name: "",
                    amount: nil,
                    icon: "plus.circle.fill",
                    color: "#4CAF50"
                )
            } else {
                let income = viewModel.incomes[indexPath.item]
                cell.configure(
                    name: income.name,
                    amount: income.amount,
                    icon: income.icon,
                    color: income.color
                )
            }
        case 1:
            if indexPath.item == viewModel.wallets.count {
                cell.configure(
                    name: "",
                    amount: nil,
                    icon: "plus.circle.fill",
                    color: "#007AFF"
                )
            } else {
                cell.configureForWallet(viewModel.wallets[indexPath.item])
            }
        case 2:
            if indexPath.item == viewModel.categories.count {
                cell.configure(
                    name: "",
                    amount: nil,
                    icon: "plus.circle.fill",
                    color: "#FF6B6B"
                )
            } else {
                cell.configureForCategory(viewModel.categories[indexPath.item])
            }
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
                header.configure(title: "Расходы", amount: viewModel.totalExpenses)
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
            if indexPath.item < viewModel.incomes.count {
                let income = viewModel.incomes[indexPath.item]
                let itemProvider = NSItemProvider()
                let dragItem = UIDragItem(itemProvider: itemProvider)
                dragItem.localObject = ("income", income)
                impactFeedbackGenerator.prepare()
                return [dragItem]
            }
            return []
        case 1: // Кошельки
            if indexPath.item < viewModel.wallets.count {
                let wallet = viewModel.wallets[indexPath.item]
                let itemProvider = NSItemProvider()
                let dragItem = UIDragItem(itemProvider: itemProvider)
                dragItem.localObject = ("wallet", wallet)
                impactFeedbackGenerator.prepare()
                return [dragItem]
            }
            return []
        default:
            return []
        }
    }

    func collectionView(_ collectionView: UICollectionView, dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        guard let cell = collectionView.cellForItem(at: indexPath) as? MoneyCollectionViewCell else {
            return nil
        }

        impactFeedbackGenerator.impactOccurred()
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
        // Получаем источник из локальной сессии drag
        let localDragItem = session.localDragSession?.items.first
        let sourceTuple = localDragItem?.localObject as? (String, Any)

        // Снимаем подсветку, если ушли с ячейки
        guard let indexPath = destinationIndexPath, let (sourceType, sourceObject) = sourceTuple else {
            if let lastPath = lastHighlightedIndexPath {
                highlightCell(at: lastPath, isHighlighted: false)
                lastHighlightedIndexPath = nil
            }
            return UICollectionViewDropProposal(operation: .move)
        }

        let isValid = validateDrop(sourceType: sourceType, sourceObject: sourceObject, to: indexPath)

        if isValid {
            if lastHighlightedIndexPath != indexPath {
                if let lastPath = lastHighlightedIndexPath {
                    highlightCell(at: lastPath, isHighlighted: false)
                }
                highlightCell(at: indexPath, isHighlighted: true)
                lastHighlightedIndexPath = indexPath
                impactFeedbackGenerator.impactOccurred()
                impactFeedbackGenerator.prepare()
            }
        } else {
            if let lastPath = lastHighlightedIndexPath {
                highlightCell(at: lastPath, isHighlighted: false)
                lastHighlightedIndexPath = nil
            }
        }

        return UICollectionViewDropProposal(operation: .move)
    }

    func collectionView(_ collectionView: UICollectionView, dropSessionDidEnd session: UIDropSession) {
        if let lastPath = lastHighlightedIndexPath {
            highlightCell(at: lastPath, isHighlighted: false)
            lastHighlightedIndexPath = nil
        }
    }

    private func highlightCell(at indexPath: IndexPath, isHighlighted: Bool) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? MoneyCollectionViewCell else { return }

        UIView.animate(withDuration: 0.05) {
            cell.alpha = isHighlighted ? 0.5 : 1.0
        }
    }

    private func validateDrop(sourceType: String, sourceObject: Any, to destinationIndexPath: IndexPath) -> Bool {
        switch (sourceType, destinationIndexPath.section) {
        case ("income", 1):
            return viewModel.wallet(at: destinationIndexPath) != nil
        case ("wallet", 1):
            guard let sourceWallet = sourceObject as? WalletModel,
                  let targetWallet = viewModel.wallet(at: destinationIndexPath) else { return false }
            return sourceWallet.id != targetWallet.id
        case ("wallet", 2):
            return viewModel.category(at: destinationIndexPath) != nil
        default:
            return false
        }
    }
}

// MARK: - Helper Methods
private extension MainViewController {
    func showTransferBottomSheet(for transferType: TransferType) {
        viewModel.presentTransfer(type: transferType, delegate: self)
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
        switch indexPath.section {
        case 0: // Income
            if indexPath.item == viewModel.incomes.count {
                viewModel.showAddNewItem(type: .income)
            } else if let income = viewModel.incomes[safe: indexPath.item] {
                viewModel.showTransactions(for: .income(income))
            }
        case 1: // Wallets
            if indexPath.item == viewModel.wallets.count {
                viewModel.showAddNewItem(type: .wallet)
            } else if let wallet = viewModel.wallets[safe: indexPath.item] {
                viewModel.showTransactions(for: .wallet(wallet))
            }
        case 2: // Categories
            if indexPath.item == viewModel.categories.count {
                viewModel.showAddNewItem(type: .category)
            } else if let category = viewModel.categories[safe: indexPath.item] {
                viewModel.showTransactions(for: .category(category))
            }
        default:
            break
        }
    }

    func resetTransferState() {
        pendingTransferWallet = nil
        lastHighlightedIndexPath = nil
    }
}

// MARK: - TransferBottomSheetDelegate
extension MainViewController: TransferBottomSheetDelegate {
    func transferBottomSheet(transferType: TransferType, didConfirmAmount amount: Double, date: Date, comment: String?) {
        viewModel.handleTransfer(type: transferType, amount: amount, date: date, comment: comment)

    }

    func transferBottomSheetDidCancel() {
        viewModel.сloseTransfer()
        resetTransferState()
    }
}
