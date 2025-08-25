//
//  PeriodDatePicker.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 25.08.2025.
//

import UIKit

struct PeriodSelection {
    var from: Date
    var to: Date
}

final class CustomPeriodPickerView: UIView {

    var selection = PeriodSelection(from: Date(), to: Date())
    var onDone: (() -> Void)?

    // MARK: - State
    private enum ActiveField {
        case from, to
    }
    private var activeField: ActiveField = .from

    // MARK: - UI
    private let fromButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.systemBlue, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemBlue.cgColor
        return button
    }()

    private let toButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.darkGray, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.lightGray.cgColor
        return button
    }()

    let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .inline
        return picker
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupUI() {
        let buttonsStack = UIStackView(arrangedSubviews: [fromButton, toButton])
        buttonsStack.axis = .horizontal
        buttonsStack.distribution = .fillEqually
        buttonsStack.spacing = 8

        let stack = UIStackView(arrangedSubviews: [buttonsStack, datePicker])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])


        let df = DateFormatter()
        df.dateStyle = .medium
        fromButton.setTitle("С: \(df.string(from: selection.from))", for: .normal)
        toButton.setTitle("ПО: \(df.string(from: selection.to))", for: .normal)

        onDone?()
    }

    private func setupActions() {
        fromButton.addTarget(self, action: #selector(selectFrom), for: .touchUpInside)
        toButton.addTarget(self, action: #selector(selectTo), for: .touchUpInside)
        datePicker.addTarget(self, action: #selector(datePicked), for: .valueChanged)
    }

    // MARK: - Actions
    @objc private func selectFrom() {
        activeField = .from
        updateActiveField()
    }

    @objc private func selectTo() {
        activeField = .to
        updateActiveField()
    }

    @objc private func datePicked() {
        let picked = datePicker.date
        let formatter = DateFormatter()
        formatter.dateStyle = .medium

        switch activeField {
        case .from:
            selection.from = picked
            fromButton.setTitle("С: \(formatter.string(from: picked))", for: .normal)
        case .to:
            selection.to = picked
            toButton.setTitle("ПО: \(formatter.string(from: picked))", for: .normal)
        }

//        validateSelection()
        onDone?()
    }

    private func updateActiveField() {
        switch activeField {
        case .from:
            fromButton.setTitleColor(.systemBlue, for: .normal)
            fromButton.layer.borderColor = UIColor.systemBlue.cgColor

            toButton.setTitleColor(.darkGray, for: .normal)
            toButton.layer.borderColor = UIColor.lightGray.cgColor
        case .to:
            toButton.setTitleColor(.systemBlue, for: .normal)
            toButton.layer.borderColor = UIColor.systemBlue.cgColor

            fromButton.setTitleColor(.darkGray, for: .normal)
            fromButton.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
}




