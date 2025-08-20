//
//  SelectPeriodViewController.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 15.08.2025.
//

import UIKit
import Combine
import SnapKit

enum PeriodType: String, CaseIterable {
    case week = "Неделя"
    case month = "Месяц"

    var displayTitle: String {
        switch self {
        case .week:
            return "Неделя"
        case .month:
            return Date().monthName // ← текущий месяц
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

    private lazy var applyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Применить", for: .normal)
        button.addTarget(self, action: #selector(apply), for: .touchUpInside)
        return button
    }()

    init(viewModel: SelectPeriodViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

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
        navigationController?.popViewController(animated: true)
    }

    private func setupUI() {
        title = viewModel.screenTitle
        view.backgroundColor = .systemBackground
        view.addSubview(stackView)
        view.addSubview(applyButton)

        stackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(PeriodType.allCases.count * 70)
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
    }

    private func updateSelection(_ selected: PeriodType) {
        for case let button as RadioButton in stackView.arrangedSubviews {
            button.isChecked = (button.period == selected)
        }
    }
}

extension Date {
    var monthName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU") // ← для русского языка
        formatter.dateFormat = "LLLL yyyy"             // название месяца + год
        return formatter.string(from: self).capitalized
    }
}
