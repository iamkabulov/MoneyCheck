import UIKit
import SnapKit
import Foundation

enum TransferType {
    case income(sourceIncome: IncomeModel, targetWallet: WalletModel)
    case wallet(sourceWallet: WalletModel, targetWallet: WalletModel)
    case category(sourceWallet: WalletModel, targetCategory: CategoryModel)
    
    var title: String {
        switch self {
        case .income(let income, let wallet):
            return "Перевести из \(income.name) в \(wallet.name)"
        case .wallet(let source, let target):
            return "Перевести из \(source.name) в \(target.name)"
        case .category(let wallet, let category):
            return "Перевести из \(wallet.name) в \(category.name)"
        }
    }
}

protocol TransferBottomSheetDelegate: AnyObject {
    func transferBottomSheet(_ viewController: TransferBottomSheetViewController, didConfirmAmount amount: Double)
    func transferBottomSheetDidCancel(_ viewController: TransferBottomSheetViewController)
}

final class TransferBottomSheetViewController: UIViewController {
    // MARK: - Properties
    weak var delegate: TransferBottomSheetDelegate?
    let transferType: TransferType
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .label
        return label
    }()
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Сумма"
        textField.keyboardType = .decimalPad
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .secondarySystemGroupedBackground
        textField.textColor = .label
        return textField
    }()
    
    private let buttonsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        return stack
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отмена", for: .normal)
        button.setTitleColor(UIColor(hex: "#FF3B30"), for: .normal)
        button.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.transferBottomSheetDidCancel(self)
            self.dismiss(animated: true)
        }, for: .touchUpInside)
        return button
    }()
    
    private lazy var okButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("OK", for: .normal)
        button.setTitleColor(UIColor(hex: "#007AFF"), for: .normal)
        button.addAction(UIAction { [weak self] _ in
            guard let self = self,
                  let amountText = self.textField.text,
                  let amount = Double(amountText.replacingOccurrences(of: ",", with: ".")),
                  amount > 0 else {
                return
            }
            self.delegate?.transferBottomSheet(self, didConfirmAmount: amount)
            self.dismiss(animated: true)
        }, for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initialization
    init(transferType: TransferType) {
        self.transferType = transferType
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .custom
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textField.becomeFirstResponder()
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        titleLabel.text = transferType.title
        
        view.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(textField)
        containerView.addSubview(buttonsStack)
        
        buttonsStack.addArrangedSubview(cancelButton)
        buttonsStack.addArrangedSubview(okButton)
        
        containerView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
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
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.height.equalTo(44)
        }
    }
} 
