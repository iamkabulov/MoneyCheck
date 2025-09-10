import UIKit
import SnapKit
import Combine

class ItemViewController: UIViewController {
    // MARK: - Properties
    private let viewModel: any ItemViewModelProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI Components
    private lazy var nameField: UITextField = {
        let field = UITextField()
        field.placeholder = "Название"
        field.borderStyle = .roundedRect
        field.backgroundColor = .systemBackground
        field.autocorrectionType = .no
        field.returnKeyType = .done
        return field
    }()

    private lazy var iconsView = PagedCollectionView(
        title: "Иконка",
        itemSize: CGSize(width: 50, height: 50)
    )

    private lazy var colorsView = PagedCollectionView(
        title: "Цвет",
        itemSize: CGSize(width: 40, height: 40)
    )

    private lazy var saveButton: PrimaryButton = {
        let button = PrimaryButton(type: .system)
        button.setTitle("Сохранить", for: .normal)
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var deleteButton = UIBarButtonItem()

    // MARK: - Initialization
    init(viewModel: ItemViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("Deinit ItemViewController")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupBindings()
        setupKeyboardDismissGesture()

        if viewModel is EditItemViewModel {
            deleteButton.title = "Удалить"
            deleteButton.target = self
            deleteButton.action = #selector(deleteItem)
            navigationItem.rightBarButtonItem = deleteButton
            navigationItem.rightBarButtonItem?.tintColor = .systemRed
        }

        iconsView.collectionView.delegate = self
        iconsView.collectionView.dataSource = self
        colorsView.collectionView.delegate = self
        colorsView.collectionView.dataSource = self

        iconsView.collectionView.register(
            IconCell.self,
            forCellWithReuseIdentifier: IconCell.reuseIdentifier
        )
        colorsView.collectionView.register(
            ColorCell.self,
            forCellWithReuseIdentifier: ColorCell.reuseIdentifier
        )
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        iconsView.updatePages(itemsCount: viewModel.icons.count - 1)
        colorsView.updatePages(itemsCount: viewModel.colors.count - 1)

        // Скролл к выбранной иконке
        if let index = viewModel.icons.firstIndex(of: viewModel.selectedIcon) {
            let indexPath = IndexPath(item: index, section: 0)
            iconsView.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
        // Скролл к выбранному цвету
        if let index = viewModel.colors.firstIndex(of: viewModel.selectedColor) {
            let indexPath = IndexPath(item: index, section: 0)
            colorsView.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }

    @objc private func deleteItem() {
        guard let vm = viewModel as? EditItemViewModel else { return }
        vm.deleteItem()
    }

    // MARK: - Private Methods
    private func setupBindings() {
        nameField.textPublisher
            .assign(to: \.name, on: viewModel)
            .store(in: &cancellables)

        viewModel.namePublisher
            .sink { [weak self] value in
                self?.nameField.text = value
            }
            .store(in: &cancellables)

        viewModel.selectedIconPublisher
            .sink { [weak self] _ in
                self?.iconsView.collectionView.reloadData()
            }
            .store(in: &cancellables)

        viewModel.selectedColorPublisher
            .sink { [weak self] _ in
                self?.colorsView.collectionView.reloadData()
                self?.iconsView.collectionView.reloadData()
            }
            .store(in: &cancellables)
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = viewModel.type.title

        view.addSubview(nameField)
        view.addSubview(iconsView)
        view.addSubview(colorsView)
        view.addSubview(saveButton)
    }

    private func setupConstraints() {
        nameField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }

        iconsView.snp.makeConstraints { make in
            make.top.equalTo(nameField.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(120)
        }

        colorsView.snp.makeConstraints { make in
            make.top.equalTo(iconsView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(120)
        }

        saveButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }

    // MARK: - Actions
    @objc private func saveButtonTapped() {
        viewModel.saveItem()
    }
}

// MARK: - UICollectionViewDataSource
extension ItemViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == iconsView.collectionView {
            return viewModel.icons.count
        } else {
            return viewModel.colors.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == iconsView.collectionView {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: IconCell.reuseIdentifier,
                for: indexPath
            ) as? IconCell else { return UICollectionViewCell() }
            let icon = viewModel.icons[indexPath.item]
            cell.configure(with: icon, color: viewModel.selectedColor, selectedIcon: viewModel.selectedIcon)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ColorCell.reuseIdentifier,
                for: indexPath
            ) as? ColorCell else { return UICollectionViewCell() }
            let color = viewModel.colors[indexPath.item]
            cell.configure(with: color, selectedColor: viewModel.selectedColor)
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegate
extension ItemViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == iconsView.collectionView {
            viewModel.selectedIcon = viewModel.icons[indexPath.item]
        } else {
            viewModel.selectedColor = viewModel.colors[indexPath.item]
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == iconsView.collectionView {
            iconsView.updateCurrentPage(scrollView: scrollView)
        } else if scrollView == colorsView.collectionView {
            colorsView.updateCurrentPage(scrollView: scrollView)
        }
    }
}
