//
//  SelectPeriodViewController.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 15.08.2025.
//

import UIKit
import Combine
import SnapKit

enum PeriodType: Equatable {

    static var allCases: [PeriodType] {
        return [
            .week,
//            .lastMonth,
            .month,
//            .wholeTime
        ]
    }

    case week
    case lastMonth
    case month
    case custom(Date, Date)
    case wholeTime

    /// ID для хранения в CoreData
    var id: Int {
        switch self {
        case .week: return 0
        case .lastMonth: return 1
        case .month: return 2
        case .custom: return 3
        case .wholeTime: return 4
        }
    }

    /// Локализованное имя (для UI)
    var displayTitle: String {
        switch self {
            case .week:
                return String(localized: "week")
            case .lastMonth:
                return String(localized: "lastMonth")
            case .month:
                return String(localized: "month")
            case .custom:
                return String(localized: "customPeriod")
            case .wholeTime:
                return String(localized: "wholeTime")
        }
    }

    /// Восстановление из CoreData
    static func from(id: Int, from: Date? = nil, to: Date? = nil) -> PeriodType? {
        switch id {
        case 0: return .week
        case 1: return .lastMonth
        case 2: return .month
        case 3:
            if let from, let to {
                return .custom(from, to)
            }
            return nil
        case 4: return .wholeTime
        default:
            return nil
        }
    }
}

final class SelectPeriodViewController: UIViewController {
    private let contentView = UIView()

    private let viewModel: SelectPeriodViewModel
    private var cancellables = Set<AnyCancellable>()

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

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        return stackView
    }()

    private lazy var applyButton: PrimaryButton = {
        let button = PrimaryButton()
        button.setTitle(String(localized: "apply"), for: .normal)
        button.addTarget(self, action: #selector(apply), for: .touchUpInside)
        return button
    }()

    init(viewModel: SelectPeriodViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    deinit {
        print("Select Period VC deinit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }

    private func bindViewModel() {
        viewModel.$selectedPeriod
            .receive(on: DispatchQueue.main)
            .sink { [weak self] period in
                self?.updateSelection(period)
            }
            .store(in: &cancellables)
    }

    @objc private func apply() {
        viewModel.savePeriod(viewModel.selectedPeriod)
    }

    @objc private func cancelTapped() {
        viewModel.dismiss(self)
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(contentView)

        contentView.addSubview(titleLabel)
        contentView.addSubview(cancelButton)
        contentView.addSubview(stackView)
        contentView.addSubview(applyButton)

        contentView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(16)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        cancelButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalTo(titleLabel)
        }

        stackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        // 🔑 Spacer для гибкого расстояния
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .vertical)
        contentView.addSubview(spacer)
        spacer.snp.makeConstraints {
            $0.top.equalTo(stackView.snp.bottom)
            $0.bottom.equalTo(applyButton.snp.top).offset(-44)
            $0.leading.trailing.equalToSuperview()
        }

        applyButton.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview().inset(16)
        }

        PeriodType.allCases.forEach { period in
            let button = RadioButton(period: period) { [weak self] selected in
                self?.viewModel.selectedPeriod = selected
            }
            stackView.addArrangedSubview(button)
        }

        switch viewModel.selectedPeriod {
            case .custom(let from, let to):
                let button = RadioButton(period: .custom(from, to)) { [weak self] selected in
                    guard let self else { return }
                    self.viewModel.customPeriodChose(self)
                    self.viewModel.selectedPeriod = selected
                }
                stackView.addArrangedSubview(button)
            default:
                let button = RadioButton(period: .custom(Date(), Date())) { [weak self] selected in
                    guard let self else { return }
                    self.viewModel.customPeriodChose(self)
                    self.viewModel.selectedPeriod = selected
                }
                stackView.addArrangedSubview(button)
        }
    }

    private func updateSelection(_ selected: PeriodType) {
        for case let button as RadioButton in stackView.arrangedSubviews {
            button.isChecked = (button.period.id == selected.id)

            if case .custom(_, _) = button.period {
                switch selected {
                    case .custom(let from, let to):
                        button.updateTitle(String(localized: "customPeriod") + ": \(from.periodName) - \(to.periodName)")
                    default: break
                }
            }
        }
    }
}

extension Date {
    var monthName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = .current
        formatter.dateFormat = "LLLL"             // название месяца + год
        return formatter.string(from: self).capitalized
    }

    var periodName: String {
        let formatter = DateFormatter()
        formatter.timeZone = .current
        formatter.locale = Locale.current
        formatter.dateFormat = "dd.MM"
        return formatter.string(from: self).capitalized
    }
}

extension PeriodType {
    static func == (lhs: PeriodType, rhs: PeriodType) -> Bool {
        switch (lhs, rhs) {
        case (.week, .week), (.month, .month), (.lastMonth, .lastMonth), (.wholeTime, .wholeTime):
            return true
        case let (.custom(lFrom, lTo), .custom(rFrom, rTo)):
            return lFrom == rFrom && lTo == rTo
        default:
            return false
        }
    }
}
