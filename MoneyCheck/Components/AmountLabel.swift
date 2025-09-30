//
//  AmountLabel.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 12.09.2025.
//

import UIKit

final class AmountLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
        font = .preferredFont(forTextStyle: .body)
        textColor = .label
        textAlignment = .right
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func amountFormatter(_ amount: Double, sign: String? = nil) {
        guard let sign else { return self.text = Double.amountFormatter(amount) + " ₸" }
        self.text = sign + Double.amountFormatter(amount) + " ₸"
    }
}
