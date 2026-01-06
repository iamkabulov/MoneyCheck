import UIKit
import Combine
import SnapKit


final class EditTransactionViewController: UIViewController {
    private let viewModel: EditTransactionViewModel
    private var selectedDate: Date?
    private var cancellables = Set<AnyCancellable>()

    private lazy var amountInput: AmountInput = {
        let textField = AmountInput()
        textField.placeholder = "Сумма"
        textField.text = Double.amountFormatter(viewModel.transaction.amount)
        return textField
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(
            arrangedSubviews: [
                amountInput,
                commentInput,
                datePicker
            ]
        )
        stack.axis = .vertical
        stack.spacing = 24
        return stack
    }()


    private lazy var commentInput: TextInput = {
        let textField = TextInput()
        textField.placeholder = "Комментарий"
        textField.text = viewModel.transaction.comment
        return textField
    }()

    private lazy var datePicker = HorizontalDatePicker(
        initialDate: viewModel.transaction.date
    )

    private lazy var saveButton: PrimaryButton = {
        let button = PrimaryButton()
        button.setTitle(String(localized: "save"), for: .normal)
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var deleteButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.target = self
        button.action = #selector(deleteButtonTapped)
        button.title = String(localized: "delete")
        button.tintColor = .systemRed
        return button
    }()

    init(viewModel: EditTransactionViewModel) {
        self.viewModel = viewModel
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
//        navigationController?.navigationBar.prefersLargeTitles = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        navigationController?.navigationBar.prefersLargeTitles = true
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = String(localized: "Edit transaction")

        view.addSubview(stackView)
        view.addSubview(saveButton)
        stackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        datePicker.snp.makeConstraints { make in
            make.height.equalTo(50)
        }

        saveButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-16)
        }
    }
    
    @objc private func saveButtonTapped() {
        guard amountInput.validate({ text in
            !text.isEmpty
        }, message: String(localized:"Amount can't be empty")) else { return }
        viewModel.saveTransaction(amountInput.text, date: selectedDate, comment: commentInput.text)
    }

    @objc private func deleteButtonTapped() {
        viewModel.deleteTransaction()
    }
}
