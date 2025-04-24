import UIKit
import SnapKit
import Combine

enum AddItemType {
    case income
    case wallet
    case category
    
    var title: String {
        switch self {
        case .income: return "Новый доход"
        case .wallet: return "Новый кошелек"
        case .category: return "Новая категория"
        }
    }
    
    var defaultColor: String {
        switch self {
        case .income: return "#4CAF50"
        case .wallet: return "#2196F3"
        case .category: return "#F44336"
        }
    }
}

class AddItemViewController: UIViewController {
    // MARK: - Properties
    private let financeUseCase: FinanceUseCase
    private let itemType: AddItemType
    private var cancellables = Set<AnyCancellable>()
    
    private let icons = [
        "creditcard", "wallet.pass", "banknote", "dollarsign.circle",
        "cart", "bag", "basket", "gift",
        "house", "car", "bus", "airplane",
        "fork.knife", "cup.and.saucer", "wineglass",
        "heart", "star", "person", "gamecontroller",
        "plus.circle.fill"
    ]
    
    private let colors = [
        "#4CAF50", "#2196F3", "#F44336", "#FFC107", "#9C27B0",
        "#FF9800", "#00BCD4", "#795548", "#607D8B", "#E91E63"
    ]
    
    private var selectedIcon: String?
    private var selectedColor: String?
    
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
        collectionView.register(IconCell.self, forCellWithReuseIdentifier: "IconCell")
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private lazy var colorsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.itemSize = CGSize(width: 44, height: 44)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ColorCell.self, forCellWithReuseIdentifier: "ColorCell")
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
    
    // MARK: - Initialization
    init(type: AddItemType, financeUseCase: FinanceUseCase) {
        self.itemType = type
        self.financeUseCase = financeUseCase
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupKeyboardHandling()
        
        title = itemType.title
        selectedColor = colors.first
        selectedIcon = icons.first
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
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
    
    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
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
        guard let name = nameField.text, !name.isEmpty,
              let icon = selectedIcon,
              let color = selectedColor else {
            // TODO: Show error
            return
        }
        
        let publisher: AnyPublisher<Void, Error>
        
        switch itemType {
        case .income:
            publisher = financeUseCase.createIncome(name: name, icon: icon, color: color)
        case .wallet:
            publisher = financeUseCase.createWallet(name: name, type: .card, icon: icon)
        case .category:
            publisher = financeUseCase.createCategory(name: name, icon: icon, color: color)
        }
        
        publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.navigationController?.popToRootViewController(animated: true)
                case .failure(let error):
                    print("Error saving item: \(error)")
                    // TODO: Show error
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
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
            return icons.count
        } else {
            return colors.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == iconsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IconCell", for: indexPath) as! IconCell
            let icon = icons[indexPath.item]
            cell.configure(with: icon, color: selectedColor ?? itemType.defaultColor, selectedIcon: self.selectedIcon ?? "")
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as! ColorCell
            let color = colors[indexPath.item]
            cell.configure(with: color, selectedColor: self.selectedColor ?? "")
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegate
extension AddItemViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == iconsCollectionView {
            selectedIcon = icons[indexPath.item]
            iconsCollectionView.reloadData()
        } else {
            selectedColor = colors[indexPath.item]
            iconsCollectionView.reloadData()
            colorsCollectionView.reloadData()
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

// MARK: - IconCell
final class IconCell: UICollectionViewCell {
    private let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.layer.cornerRadius = self.bounds.width / 2
        contentView.addSubview(iconView)
        
        iconView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
    }
    
    func configure(with icon: String, color: String, selectedIcon: String) {
        iconView.image = UIImage(systemName: icon)
        contentView.backgroundColor = UIColor(hex: color)
        if selectedIcon == icon {
            transform = CGAffineTransform(scaleX: 1, y: 1)
        } else {
            transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        }
    }
}

// MARK: - ColorCell
final class ColorCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        layer.cornerRadius = self.bounds.width / 2
    }
    
    func configure(with color: String, selectedColor: String) {
        backgroundColor = UIColor(hex: color)
        if selectedColor == color {
            transform = CGAffineTransform(scaleX: 1, y: 1)
        } else {
            transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        }
    }
}
