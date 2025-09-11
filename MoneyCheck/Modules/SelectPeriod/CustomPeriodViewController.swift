import UIKit
import SnapKit

final class CustomPeriodViewController: UIViewController {

    private let periodPicker = CustomPeriodPickerView()
    private let viewModel: SelectPeriodViewModel

    private lazy var doneButton: PrimaryButton = {
        let button = PrimaryButton()
        button.setTitle("Готово", for: .normal)
        button.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        return button
    }()

    init(viewModel: SelectPeriodViewModel) {
        self.viewModel = viewModel
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
        self.setupUI()
    }

    private func setupUI() {
        title = "Выбор периода"
        view.backgroundColor = .systemBackground

        view.addSubview(periodPicker)
        view.addSubview(doneButton)

        periodPicker.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(20)
        }

        doneButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(50)
        }

        periodPicker.onDone = { [weak self] in
            self?.validateSelection()
        }

        switch viewModel.selectedPeriod {
            case .custom(let from, let to):
                periodPicker.selection = PeriodSelection(from: from, to: to)
            default:
                periodPicker.selection = PeriodSelection(from: Date(), to: Date())
        }
    }

    private func validateSelection() {
        let calendar = Calendar.current
        if calendar.compare(periodPicker.selection.from, to: periodPicker.selection.to, toGranularity: .day) != .orderedDescending {
            doneButton.setEnabled(true)
        } else {
            doneButton.setEnabled(false)
        }
    }

    @objc private func doneTapped() {
        self.validateSelection()
        viewModel.saveCustomPeriod(.custom(periodPicker.selection.from, periodPicker.selection.to))
    }
}
