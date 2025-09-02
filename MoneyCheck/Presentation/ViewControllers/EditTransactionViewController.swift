import UIKit
import Combine
import SnapKit


final class EditTransactionViewController: UIViewController {
    private let viewModel: EditTransactionViewModel
    private var selectedDate: Date?
    private var cancellables = Set<AnyCancellable>()

    private lazy var amountTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Сумма"
        textField.keyboardType = .decimalPad
        textField.borderStyle = .roundedRect
        textField.text = String(viewModel.transaction.amount)
        return textField
    }()

    private lazy var commentInput: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Комментарий"
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .secondarySystemGroupedBackground
        textField.textColor = .label
        textField.text = viewModel.transaction.comment
        return textField
    }()

    private lazy var datePicker = HorizontalDatePicker(
        initialDate: viewModel.transaction.date
    )

    private lazy var saveButton: PrimaryButton = {
        let button = PrimaryButton()
        button.setTitle("Сохранить", for: .normal)
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var deleteButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.target = self
        button.action = #selector(deleteButtonTapped)
        button.title = "Удалить"
        button.tintColor = .systemRed
        return button
    }()

    init(vm: EditTransactionViewModel) {
        self.viewModel = vm
        super.init(nibName: nil, bundle: nil)
        datePicker.onDateSelected = { [weak self] date in
            self?.selectedDate = date
        }

        navigationItem.rightBarButtonItem = deleteButton
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
        setupKeyboardDismissGesture()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        navigationController?.navigationBar.prefersLargeTitles = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        navigationController?.navigationBar.prefersLargeTitles = true
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Редактирование транзакции"
        let stackView = UIStackView(
            arrangedSubviews: [
                amountTextField,
                commentInput,
                datePicker,
                saveButton
            ]
        )
        stackView.axis = .vertical
        stackView.spacing = 16
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        datePicker.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
    }
    
    @objc private func saveButtonTapped() {
        viewModel.saveTransaction(amountTextField.text, date: selectedDate, comment: commentInput.text)
    }

    @objc private func deleteButtonTapped() {
        viewModel.deleteTransaction()
    }
}
