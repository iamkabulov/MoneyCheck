//
//  RadioButton.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 15.08.2025.
//
import UIKit

class RadioButton: UIView {
    let period: Period
    var isChecked: Bool = false {
        didSet { updateUI() }
    }
    let radioButton = UIImageView()
    let label = UILabel()
    private let tapHandler: (Period) -> Void

    override init(frame: CGRect) {
        self.period = .week
        self.tapHandler = { _ in }
        super.init(frame: frame)
    }

    init(period: Period, onTap: @escaping (Period) -> Void) {
        self.tapHandler = onTap
        self.period = period
        super.init(frame: .zero)
        createSubViews(text: period.rawValue)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)

        updateUI()
    }

    required init?(coder: NSCoder) {
        self.period = .week
        self.tapHandler = { _ in }
        super.init(coder: coder)
    }

    private func createSubViews(text: String) {
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
        layer.cornerRadius = 8

        label.textColor = .label
        label.numberOfLines = 0
        label.text = text
        label.textAlignment = .left

        addSubview(label)
        label.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }

        radioButton.image = UIImage(systemName: "circle")
        radioButton.contentMode = .scaleAspectFit
        radioButton.tintColor = .label

        addSubview(radioButton)
        radioButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.height.width.equalTo(24)
            make.centerY.equalToSuperview()
        }
    }

    @objc private func handleTap() {
        tapHandler(period)
    }

    func toggle() {
        isChecked.toggle()
    }

    private func updateUI() {
        radioButton.image = isChecked ? UIImage(systemName: "checkmark.circle") : UIImage(systemName: "circle")
    }
}

