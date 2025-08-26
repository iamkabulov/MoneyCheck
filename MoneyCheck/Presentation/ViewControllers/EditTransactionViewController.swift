import UIKit
import Combine
import SnapKit


//TODO: - Создать отдельно ViewModel
final class EditTransactionViewController: UIViewController {
    private let viewModel: EditTransactionViewModel
    private var cancellables = Set<AnyCancellable>()

    private lazy var amountTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Сумма"
        textField.keyboardType = .decimalPad
        textField.borderStyle = .roundedRect
        textField.text = String(viewModel.transaction.amount)
        return textField
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .inline
        picker.date = viewModel.transaction.date
        return picker
    }()
    
    private lazy var saveButton: PrimaryButton = {
        let button = PrimaryButton()
        button.setTitle("Сохранить", for: .normal)
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()
    
    init(vm: EditTransactionViewModel) {
        self.viewModel = vm
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
    
    @objc private func saveButtonTapped() {
        viewModel.saveTransaction(amountTextField.text, date: datePicker.date)
    }
}
