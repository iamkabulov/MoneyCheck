//
//  ReminderViewController.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 10.01.2026.
//


import UIKit
import Combine
import SnapKit

final class ReminderViewController: UIViewController {

    private let viewModel: ReminderViewModel
    private var cancellables = Set<AnyCancellable>()

    private let datePicker = UIDatePicker()
    private var didSave = false

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = String(localized: "reminder_settings")
        return label
    }()

    private let saveButton: PrimaryButton = {
        let button = PrimaryButton()
        button.setTitle(String(localized: "save"), for: .normal)
        return button
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .systemGray3
        button.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
                cancelTapped()
        }, for: .touchDown)
        return button
    }()
    

    init(viewModel: ReminderViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    deinit {
        print("Deinited ReminderViewController")
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
            datePicker
        ])
        stack.axis = .vertical
        stack.spacing = 20

        view.addSubview(stack)
        view.addSubview(saveButton)
        view.addSubview(cancelButton)

        stack.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(24)
        }

        saveButton.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview().inset(32)
        }

        cancelButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.trailing.equalToSuperview().inset(16)
        }
    }

    private func bind() {
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
    }

    @objc private func saveTapped() {
        didSave = true
        viewModel.saveReminder(self.datePicker.date)
        viewModel.closeReminderView(didSave: true, time: datePicker.date)
    }

    @objc private func cancelTapped() {
        viewModel.closeReminderView(didSave: false, time: datePicker.date)
    }
}
