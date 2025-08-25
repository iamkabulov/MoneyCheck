import UIKit

final class CustomPeriodViewController: UIViewController {

    private let periodPicker = CustomPeriodPickerView()
    private let viewModel: SelectPeriodViewModel
    private let router: SelectPeriodRouting

    private lazy var doneButton: PrimaryButton = {
        let button = PrimaryButton()
        button.setTitle("Готово", for: .normal)
        button.setEnabled(false)
        button.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        return button
    }()

    init(viewModel: SelectPeriodViewModel, router: SelectPeriodRouting) {
        self.viewModel = viewModel
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("DELETED: CustomPeriodViewController")
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Выбор периода"
        view.backgroundColor = .systemBackground

        view.addSubview(periodPicker)
        view.addSubview(doneButton)

        periodPicker.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        doneButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(50)
        }

        periodPicker.onDone = { [weak self] in
            self?.validateSelection()
        }
    }


    private func validateSelection() {
        if periodPicker.selection.from <= periodPicker.selection.to {
            doneButton.setEnabled(true)
        } else {
            doneButton.setEnabled(false)
        }
    }

    @objc private func doneTapped() {
        self.validateSelection()
        viewModel.selectedPeriod = .custom(periodPicker.selection.from, periodPicker.selection.to)
        router.closeCustomPeriodView()
    }
}
