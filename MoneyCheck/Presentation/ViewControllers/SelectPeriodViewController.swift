//
//  SelectPeriodViewController.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 15.08.2025.
//

import UIKit
import Combine
import SnapKit

enum Period: String, CaseIterable {
    case week = "Неделя"
    case month = "Месяц"
}

protocol SelectPeriodViewControllerProtocol: AnyObject {
}

final class SelectPeriodViewController: UIViewController {

    var selectedPeriod: Period = .month

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 4
        return stackView
    }()

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(100)
        }

        for period in Period.allCases {
            let button = RadioButton(period: period) { [weak self] selectedPeriod in
                self?.didTapCheckbox(period: selectedPeriod)
            }
            if period == selectedPeriod {
                button.isChecked = true
            }
            stackView.addArrangedSubview(button)
        }
    }

    private func didTapCheckbox(period: Period) {
        for case let button as RadioButton in stackView.arrangedSubviews {
            button.isChecked = (button.period == period)
        }
        print("Selected period: \(period)")
    }
}
