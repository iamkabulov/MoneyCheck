//
//  CalendarPanModalViewController.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 06.01.2026.
//


import UIKit
import PanModal
import SnapKit

final class CalendarPanModalViewController: UIViewController {

    // MARK: - Public
    var onDateSelected: ((Date) -> Void)?

    // MARK: - UI

    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .inline
        return picker
    }()

    private let doneButton = PrimaryButton()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground
        doneButton.setTitle(String(localized: "done"), for: .normal)

        view.addSubview(datePicker)
        view.addSubview(doneButton)

        datePicker.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        doneButton.snp.makeConstraints { make in
            make.top.equalTo(datePicker.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(40)
        }
    }

    // MARK: - Actions

    @objc private func doneTapped() {
        onDateSelected?(datePicker.date)
        dismiss(animated: true)
    }
}

extension CalendarPanModalViewController: PanModalPresentable {

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
