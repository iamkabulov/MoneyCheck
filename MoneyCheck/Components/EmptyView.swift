//
//  EmptyView.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 21.12.2025.
//

import UIKit
import SnapKit

final class EmptyView: UIView {
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Нет данных"
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = .systemGray
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension EmptyView {
    func setup() {
        addSubview(label)

        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
