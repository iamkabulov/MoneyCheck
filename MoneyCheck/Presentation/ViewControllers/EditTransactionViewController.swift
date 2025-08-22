import UIKit
import Combine
import SnapKit

protocol EditTransactionDelegate: AnyObject {
    func editTransactionViewController(_ controller: EditTransactionViewController, didUpdate transaction: TransactionModel)
}

//TODO: - Создать отдельно ViewModel
final class EditTransactionViewController: UIViewController {
    private let transaction: TransactionModel
    private let financeUseCase: FinanceUseCase
    weak var delegate: EditTransactionDelegate?
    
    private lazy var amountTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Сумма"
        textField.keyboardType = .decimalPad
        textField.borderStyle = .roundedRect
        textField.text = String(transaction.amount)
        return textField
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .inline
        picker.date = transaction.date
        return picker
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Сохранить", for: .normal)
        button.addAction(UIAction { [weak self] _ in
            self?.saveTransaction()
        }, for: .touchUpInside)
        return button
    }()
    
    init(transaction: TransactionModel, financeUseCase: FinanceUseCase) {
        self.transaction = transaction
        self.financeUseCase = financeUseCase
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("EditTransactionViewController deinit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Редактирование транзакции"
        let stackView = UIStackView(arrangedSubviews: [amountTextField, datePicker, saveButton])
        stackView.axis = .vertical
        stackView.spacing = 16
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }
    
    private func saveTransaction() {
        guard let amountText = amountTextField.text,
              let amount = Double(amountText.replacingOccurrences(of: ",", with: ".")),
              amount > 0 else {
            return
        }
        
        let updatedTransaction = TransactionModel(
            id: transaction.id,
            date: datePicker.date,
            amount: amount,
            type: transaction.type,
            sourceId: transaction.sourceId,
            sourceName: transaction.sourceName,
            sourceIcon: transaction.sourceIcon,
            sourceColor: transaction.sourceColor,
            destinationId: transaction.destinationId,
            destinationName: transaction.destinationName,
            destinationIcon: transaction.destinationIcon,
            destinationColor: transaction.destinationColor
        )
        
        financeUseCase.updateTransaction(updatedTransaction)
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error): print("Error updating transaction: \(error)")
                }
            } receiveValue: { [weak self] _ in
                self?.delegate?
                    .editTransactionViewController(
                        self!,
                        didUpdate: updatedTransaction
                    )
                self?.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
} 
