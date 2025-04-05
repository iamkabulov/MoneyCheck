import UIKit
import Combine

final class MainViewController: UIViewController, UICollectionViewDelegate {
    // MARK: - Properties
    private let viewModel: MainViewModel
    let router: MainRouter
    private var cancellables = Set<AnyCancellable>()
    
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
        collectionView.register(WalletCollectionViewCell.self, forCellWithReuseIdentifier: WalletCollectionViewCell.reuseIdentifier)
        collectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.reuseIdentifier)
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
    }
    
    // MARK: - Private methods
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "MoneyCheck"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
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
            if sectionIndex == 0 {
                return self?.createWalletsSection()
            } else {
                return self?.createCategoriesSection()
            }
        }
        return layout
    }
    
    private func createWalletsSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                            heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(100),
                                             heightDimension: .absolute(100))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 16
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        
        return section
    }
    
    private func createCategoriesSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                            heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                             heightDimension: .absolute(100))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 3)
        group.interItemSpacing = .fixed(16)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        
        return section
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(title: "Ошибка", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showAmountInput(sourceWallet: WalletModel, destinationIndexPath: IndexPath) {
        let vc = UIViewController()
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        vc.modalPresentationStyle = .overFullScreen
        
        let containerView = UIView()
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 16
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = "Введите сумму"
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let textField = UITextField()
        textField.placeholder = "Сумма"
        textField.keyboardType = .decimalPad
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let buttonsStack = UIStackView()
        buttonsStack.axis = .horizontal
        buttonsStack.distribution = .fillEqually
        buttonsStack.spacing = 8
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false
        
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Отмена", for: .normal)
        cancelButton.addAction(UIAction { _ in
            vc.dismiss(animated: true)
        }, for: .touchUpInside)
        
        let okButton = UIButton(type: .system)
        okButton.setTitle("OK", for: .normal)
        okButton.addAction(UIAction { [weak self] _ in
            guard let amountText = textField.text,
                  let amount = Double(amountText.replacingOccurrences(of: ",", with: ".")),
                  amount > 0 else {
                return
            }
            
            if destinationIndexPath.section == 0 {
                // Перенос между кошельками
                let targetWallet = self?.viewModel.wallets[destinationIndexPath.item]
                if sourceWallet.id != targetWallet?.id {
                    self?.viewModel.transferMoney(from: sourceWallet, to: targetWallet!, amount: amount)
                }
            } else {
                // Расход или доход
                let category = self?.viewModel.categories[destinationIndexPath.item]
                if category?.type == .expense {
                    self?.viewModel.addExpense(from: sourceWallet, to: category!, amount: amount)
                } else {
                    self?.viewModel.addIncome(to: sourceWallet, from: category!, amount: amount)
                }
            }
            
            vc.dismiss(animated: true)
        }, for: .touchUpInside)
        
        buttonsStack.addArrangedSubview(cancelButton)
        buttonsStack.addArrangedSubview(okButton)
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(textField)
        containerView.addSubview(buttonsStack)
        vc.view.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 270),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            textField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            buttonsStack.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 16),
            buttonsStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            buttonsStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            buttonsStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            buttonsStack.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Добавляем обработчик нажатия на фон для закрытия
        let tapGesture = UITapGestureRecognizer(target: vc, action: #selector(UIViewController.dismiss))
        vc.view.addGestureRecognizer(tapGesture)
        containerView.isUserInteractionEnabled = true
        
        present(vc, animated: true) {
            textField.becomeFirstResponder()
        }
    }
}

// MARK: - UICollectionViewDataSource
extension MainViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return viewModel.wallets.count
        } else {
            return viewModel.categories.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WalletCollectionViewCell.reuseIdentifier, for: indexPath) as! WalletCollectionViewCell
            cell.configure(with: viewModel.wallets[indexPath.item])
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.reuseIdentifier, for: indexPath) as! CategoryCollectionViewCell
            cell.configure(with: viewModel.categories[indexPath.item])
            return cell
        }
    }
}

// MARK: - UICollectionViewDragDelegate
extension MainViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        if indexPath.section == 0 {
            let wallet = viewModel.wallets[indexPath.item]
            let itemProvider = NSItemProvider(object: "\(wallet.id)" as NSString)
            let dragItem = UIDragItem(itemProvider: itemProvider)
            dragItem.localObject = wallet
            return [dragItem]
        }
        return []
    }
}

// MARK: - UICollectionViewDropDelegate
extension MainViewController: UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        guard let destinationIndexPath = coordinator.destinationIndexPath,
              let dragItem = coordinator.items.first?.dragItem,
              let sourceWallet = dragItem.localObject as? WalletModel else {
            return
        }
        
        showAmountInput(sourceWallet: sourceWallet, destinationIndexPath: destinationIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        guard session.items.count == 1,
              let destinationIndexPath = destinationIndexPath else {
            return UICollectionViewDropProposal(operation: .forbidden)
        }
        
        // Всегда используем .move для визуального эффекта
        return UICollectionViewDropProposal(operation: .move)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        let cell = collectionView.cellForItem(at: indexPath)
        let parameters = UIDragPreviewParameters()
        parameters.visiblePath = UIBezierPath(roundedRect: cell?.bounds ?? .zero, cornerRadius: 16)
        return parameters
    }
}

// MARK: - Array Extension
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
} 



