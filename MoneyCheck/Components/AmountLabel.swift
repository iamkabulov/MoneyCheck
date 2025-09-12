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

    func amountFormatter(_ amount: Double) {
        self.text = Double.amountFormatter(amount) + "₸"
    }
}
