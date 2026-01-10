//
//  ReminderViewController.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 10.01.2026.
//


import UIKit
import Combine
import PanModal
import SnapKit

final class ReminderViewController: UIViewController {

    private let viewModel: ReminderViewModel
    private var cancellables = Set<AnyCancellable>()

    private let reminderSwitch = UISwitch()
    private let datePicker = UIDatePicker()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = .label
        label.textAlignment = .center
        label.text = String(localized: "reminder_settings")
        return label
    }()

    init(viewModel: ReminderViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        datePicker.datePickerMode = .time
        datePicker.preferredDatePickerStyle = .wheels

        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            reminderSwitch,
            datePicker
        ])
        stack.axis = .vertical
        stack.spacing = 16

        view.addSubview(stack)

        stack.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }

    private func bind() {
        reminderSwitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        datePicker.addTarget(self, action: #selector(timeChanged), for: .valueChanged)
    }

    @objc private func switchChanged() {
        viewModel.isEnabled = reminderSwitch.isOn
    }

    @objc private func timeChanged() {
        viewModel.time = datePicker.date
    }
}


extension ReminderViewController: PanModalPresentable {
    var panScrollable: UIScrollView? { nil }

    var shortFormHeight: PanModalHeight {
        .contentHeight(420)
    }

    var longFormHeight: PanModalHeight {
        .contentHeight(420)
    }

    var cornerRadius: CGFloat {
        20
    }

    var showDragIndicator: BooleanLiteralType {
        false
    }

    var shouldRoundTopCorners: Bool {
        true
    }
}
