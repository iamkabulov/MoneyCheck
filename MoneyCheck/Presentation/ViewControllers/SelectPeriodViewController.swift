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
            .lastMonth,
            .month
        ]
    }
    case week
    case lastMonth
    case month
    case custom(Date, Date)

    var displayTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM"

        switch self {
        case .week:
            return "Неделя"
        case .lastMonth:
            return "Прошлый месяц"
        case .month:
            return Date().monthName // ← текущий месяц
        case .custom(_, _):
            return "Период"
        }
    }
}

protocol SelectPeriodViewControllerProtocol: AnyObject {}

final class SelectPeriodViewController: UIViewController {
    private let viewModel: SelectPeriodViewModel
    private var cancellables = Set<AnyCancellable>()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 4
        return stackView
    }()

    private lazy var applyButton: PrimaryButton = {
        let button = PrimaryButton()
        button.setTitle("Применить", for: .normal)
        button.addTarget(self, action: #selector(apply), for: .touchUpInside)
        return button
    }()

    init(viewModel: SelectPeriodViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    deinit {
        print("Select Period deinit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.getPeriod()
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

    private func setupUI() {
        title = viewModel.screenTitle
        view.backgroundColor = .systemBackground
        view.addSubview(stackView)
        view.addSubview(applyButton)

        stackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo((PeriodType.allCases.count + 1) * 70)
        }

        applyButton.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
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
                    self.viewModel.customPeriodChose()
                    self.viewModel.selectedPeriod = selected
                }
                stackView.addArrangedSubview(button)
            default:
                let button = RadioButton(period: .custom(Date(), Date())) { [weak self] selected in
                    guard let self else { return }
                    self.viewModel.customPeriodChose()
                    self.viewModel.selectedPeriod = selected
                }
                stackView.addArrangedSubview(button)
        }
    }

    private func updateSelection(_ selected: PeriodType) {
        for case let button as RadioButton in stackView.arrangedSubviews {
            button.isChecked = (button.period.displayTitle == selected.displayTitle)

            if case .custom(_, _) = button.period {
                // обновляем тайтл кастомной кнопки (независимо от того, выбрана ли она)
                switch selected {
                    case .custom(let from, let to):
                        button.updateTitle("Период с \(from.periodName) - по \(to.periodName)")
                    default: break
                }
            }
        }
    }
}

extension Date {
    var monthName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU") // ← для русского языка
        formatter.timeZone = .current
        formatter.dateFormat = "LLLL"             // название месяца + год
        return formatter.string(from: self).capitalized
    }

    var periodName: String {
        let formatter = DateFormatter()
        formatter.timeZone = .current
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "dd.MM"
        return formatter.string(from: self).capitalized
    }
}

extension PeriodType {
    init?(rawValue name: String, from: Date? = nil, to: Date? = nil) {
        switch name {
            //TODO: - подумать как обойтись без строки
            case "Неделя":
                self = .week
            case "Месяц":
                self = .month
            case "Прошлый месяц":
                self = .lastMonth
            case "Период":
                if let from, let to {
                    self = .custom(from, to)
                } else {
                    return nil
                }
            default:
                return nil
        }
    }
}

extension PeriodType {
    static func == (lhs: PeriodType, rhs: PeriodType) -> Bool {
        switch (lhs, rhs) {
        case (.week, .week), (.month, .month):
            return true
        case let (.custom(lFrom, lTo), .custom(rFrom, rTo)):
            return lFrom == rFrom && lTo == rTo
        default:
            return false
        }
    }
}
