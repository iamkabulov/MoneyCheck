import UIKit
import SnapKit
import Foundation

enum TransferType {
    case income(sourceIncome: IncomeModel, targetWallet: WalletModel)
    case wallet(sourceWallet: WalletModel, targetWallet: WalletModel)
    case category(sourceWallet: WalletModel, targetCategory: CategoryModel)
    
    var title: String {
        switch self {
            case .income(_, _):
                return "Доход"
            case .wallet(_, _):
                return "Перевод"
            case .category(_, _):
                return "Расход"
        }
    }

    var fromIcon: UIImage {
        switch self {
            case .income(let income, _):
                return UIImage(systemName: income.icon) ?? UIImage()
            case .wallet(let source, _):
                return UIImage(systemName: source.icon) ?? UIImage()
            case .category(let wallet, _):
                return UIImage(systemName: wallet.icon) ?? UIImage()
        }
    }

    var toIcon: UIImage {
        switch self {
            case .income(_, let wallet):
                return UIImage(systemName: wallet.icon) ?? UIImage()
            case .wallet(_, let target):
                return UIImage(systemName: target.icon) ?? UIImage()
            case .category(_, let category):
                return UIImage(systemName: category.icon) ?? UIImage()
        }
    }

    var fromColor: UIColor {
        switch self {
            case .income(let income, _):
                return UIColor(hex: income.color)
            case .wallet(let source, _):
                return UIColor(hex: source.color)
            case .category(let wallet, _):
                return UIColor(hex: wallet.color)
        }
    }

    var toColor: UIColor {
        switch self {
            case .income(_, let wallet):
                return UIColor(hex: wallet.color)
            case .wallet(_, let target):
                return UIColor(hex: target.color)
            case .category(_, let category):
                return UIColor(hex: category.color)
        }
    }

    var fromName: String {
        switch self {
            case .income(let income, _):
                return income.name
            case .wallet(let source, _):
                return source.name
            case .category(let wallet, _):
                return wallet.name
        }
    }

    var toName: String {
        switch self {
            case .income(_, let wallet):
                return wallet.name
            case .wallet(_, let target):
                return target.name
            case .category(_, let category):
                return category.name
        }
    }
}

protocol TransferBottomSheetDelegate: AnyObject {
    func transferBottomSheet(transferType: TransferType, didConfirmAmount amount: Double, date: Date, comment: String?)
    func transferBottomSheetDidCancel()
}

final class TransferBottomSheetViewController: UIViewController {
    // MARK: - Properties
    weak var delegate: TransferBottomSheetDelegate?
    let transferType: TransferType

    private var date = Date()

    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true
        return view
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalCentering
        stackView.spacing = 20
        return stackView
    }()

    private lazy var fromIcon = CircleIconView(
        image: transferType.fromIcon,
        backgroundColor: transferType.fromColor,
        name: transferType.fromName)

    private lazy var toIcon = CircleIconView(
        image: transferType.toIcon,
        backgroundColor: transferType.toColor,
        name: transferType.toName)

    private lazy var arrowIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "arrow.right")
        imageView.tintColor = .systemGray3
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .label
        return label
    }()
    
    private lazy var amountInput: AmountInput = {
        let textField = AmountInput()
        textField.placeholder = "Сумма"
        return textField
    }()

    //TODO: - Сделать валидацию обязательных полей (СУММА)
    //TODO: - Сделать общий текстфил
    private lazy var commentInput: TextInput = {
        let textField = TextInput()
        textField.placeholder = "Комментарий"
        return textField
    }()

    private let datePicker = HorizontalDatePicker()

    private let buttonsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        return stack
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .systemGray
        button.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.transferBottomSheetDidCancel()
        }, for: .touchDown)
        return button
    }()
    
    private lazy var okButton: PrimaryButton = {
        let button = PrimaryButton(type: .system)
        button.setTitle("Сохранить", for: .normal)
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()

    @objc private func saveButtonTapped() {
        guard amountInput.validate({ !$0.isEmpty }),
              let amountText = self.amountInput.text,
              let amount = Double(amountText.replacingOccurrences(of: ",", with: ".").replacingOccurrences(of: " ", with: "")),
              amount > 0 else {
            return
        }
        self.delegate?.transferBottomSheet(transferType: transferType,didConfirmAmount: amount, date: date, comment: commentInput.text)
    }

    // MARK: - Initialization
    init(transferType: TransferType) {
        self.transferType = transferType
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        isModalInPresentation = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("TransferBottomSheet deinit")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardDismissGesture()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        datePicker.onDateSelected = { [weak self] date in
            self?.date = date
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        amountInput.becomeFirstResponder()
    }

    // MARK: - Private Methods
    private func setupUI() {
        if let sheet = sheetPresentationController {
            sheet.detents = [.custom { _ in 360 }]
        }
        self.sheetPresentationController?.prefersGrabberVisible = false
        titleLabel.text = transferType.title

        
        view.addSubview(containerView)
        containerView.addSubview(stackView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(amountInput)
        containerView.addSubview(commentInput)
        containerView.addSubview(datePicker)
        containerView.addSubview(okButton)
        containerView.addSubview(cancelButton)

        stackView.addArrangedSubview(fromIcon)
        stackView.addArrangedSubview(arrowIcon)
        stackView.addArrangedSubview(toIcon)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(cancelButton.snp.bottom).inset(4)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        stackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(100)
        }

        fromIcon.snp.makeConstraints { make in
            make.height.width.equalTo(48)
        }

        toIcon.snp.makeConstraints { make in
            make.height.width.equalTo(48)
        }

        amountInput.addDoneButtonOnKeyboard()
        amountInput.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        commentInput.addDoneButtonOnKeyboard()
        commentInput.snp.makeConstraints { make in
            make.top.equalTo(amountInput.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        datePicker.snp.makeConstraints { make in
            make.top.equalTo(commentInput.snp.bottom).offset(16)
            make.leading.equalTo(containerView.snp.leading)
            make.trailing.equalTo(containerView.snp.trailing).inset(16)
            make.height.equalTo(50)
        }

        okButton.snp.makeConstraints { make in
            make.top.equalTo(datePicker.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        cancelButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.trailing.equalToSuperview().inset(16)
        }
    }
}

