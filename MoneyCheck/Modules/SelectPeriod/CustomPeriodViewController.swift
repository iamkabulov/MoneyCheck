import UIKit
import SnapKit

final class CustomPeriodViewController: UIViewController {

    private let contentView = UIView()

    private let periodPicker = CustomPeriodPickerView()
    private let viewModel: SelectPeriodViewModel

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        label.text = viewModel.screenTitle
        return label
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .systemGray3
        button.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        return button
    }()

    private lazy var doneButton: PrimaryButton = {
        let button = PrimaryButton()
        button.setTitle(String(localized: "done"), for: .normal)
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
        view.backgroundColor = .systemBackground
        view.addSubview(contentView)

        contentView.addSubview(titleLabel)
        contentView.addSubview(cancelButton)
        contentView.addSubview(periodPicker)
        contentView.addSubview(doneButton)


        contentView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(16)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.leading.trailing.equalToSuperview()
        }

        cancelButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalTo(titleLabel)
        }

        periodPicker.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        doneButton.snp.makeConstraints {
            $0.top.equalTo(periodPicker.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(20)
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

    private func calculatedHeight() -> CGFloat {
        view.layoutIfNeeded()

        let targetSize = CGSize(
            width: view.bounds.width,
            height: UIView.layoutFittingCompressedSize.height
        )

        let height = contentView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height

        let maxHeight =
            view.bounds.height
            - view.safeAreaInsets.top
            - 12

        return min(height, maxHeight)
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
        viewModel.saveCustomPeriod(self, .custom(periodPicker.selection.from, periodPicker.selection.to))
    }

    @objc private func cancelTapped() {
        viewModel.dismiss(self)
    }
}
