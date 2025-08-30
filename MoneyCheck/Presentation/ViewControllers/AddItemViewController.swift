import UIKit
import SnapKit
import Combine

class AddItemViewController: UIViewController {
    // MARK: - Properties
    private let viewModel: any ItemViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.distribution = .fill
        return stack
    }()
    
    lazy var nameField: UITextField = {
        let field = createTextField(placeholder: "Название")
        field.delegate = self
        return field
    }()
    
    private lazy var iconsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.itemSize = CGSize(width: 60, height: 60)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(IconCell.self, forCellWithReuseIdentifier: IconCell.reuseIdentifier)
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private lazy var colorsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.itemSize = CGSize(width: 50, height: 50)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.reuseIdentifier)
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Сохранить", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
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
        print("Deinit AddItemViewController")
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
            self.navigationItem.rightBarButtonItem = deleteButton
            self.navigationItem.rightBarButtonItem?.tintColor = .systemRed
        }

    }

    @objc func deleteItem() {
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
            .sink {[weak self] _ in
                self?.iconsCollectionView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.selectedColorPublisher
            .sink { [weak self] _ in
                self?.colorsCollectionView.reloadData()
                self?.iconsCollectionView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = viewModel.type.title
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        
        stackView.addArrangedSubview(createFieldContainer(field: nameField, title: "Название"))
        
        let iconsLabel = UILabel()
        iconsLabel.text = "Иконка"
        iconsLabel.font = .systemFont(ofSize: 14, weight: .medium)
        iconsLabel.textColor = .secondaryLabel
        stackView.addArrangedSubview(iconsLabel)
        stackView.addArrangedSubview(iconsCollectionView)
        
        let colorsLabel = UILabel()
        colorsLabel.text = "Цвет"
        colorsLabel.font = .systemFont(ofSize: 14, weight: .medium)
        colorsLabel.textColor = .secondaryLabel
        stackView.addArrangedSubview(colorsLabel)
        stackView.addArrangedSubview(colorsCollectionView)
        
        stackView.addArrangedSubview(saveButton)
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
            make.height.greaterThanOrEqualToSuperview()
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.lessThanOrEqualToSuperview().offset(-20)
        }
        
        iconsCollectionView.snp.makeConstraints { make in
            make.height.equalTo(70)
        }
        
        colorsCollectionView.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        
        saveButton.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
    }
    
    private func createTextField(placeholder: String) -> UITextField {
        let field = UITextField()
        field.placeholder = placeholder
        field.borderStyle = .roundedRect
        field.backgroundColor = .systemBackground
        field.autocorrectionType = .no
        field.returnKeyType = .done
        return field
    }
    
    private func createFieldContainer(field: UITextField, title: String) -> UIView {
        let container = UIView()
        
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        
        container.addSubview(label)
        container.addSubview(field)
        
        label.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        field.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(44)
        }
        
        return container
    }
    
    // MARK: - Actions
    @objc private func saveButtonTapped() {
        viewModel.saveItem()
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
}

// MARK: - UICollectionViewDataSource
extension AddItemViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == iconsCollectionView {
            return viewModel.icons.count
        } else {
            return viewModel.colors.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == iconsCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IconCell.reuseIdentifier, for: indexPath) as? IconCell else {
                return UICollectionViewCell()
            }
            let icon = viewModel.icons[indexPath.item]
            cell
                .configure(
                    with: icon,
                    color: viewModel.selectedColor,
                    selectedIcon: viewModel.selectedIcon
                )
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.reuseIdentifier, for: indexPath) as? ColorCell else {
                return UICollectionViewCell()
            }
            let color = viewModel.colors[indexPath.item]
            cell.configure(with: color, selectedColor: viewModel.selectedColor)
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegate
extension AddItemViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == iconsCollectionView {
            viewModel.selectedIcon = viewModel.icons[indexPath.item]
            iconsCollectionView.reloadData()
        } else {
            viewModel.selectedColor = viewModel.colors[indexPath.item]
            colorsCollectionView.reloadData()
            iconsCollectionView.reloadData()
        }
    }
}

// MARK: - UITextFieldDelegate
extension AddItemViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
