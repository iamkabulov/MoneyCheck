//
//  DateCell.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 30.08.2025.
//
import UIKit
import SnapKit


class DateCell: UICollectionViewCell {
    private let label = UILabel()
    static let reuseIdentifier: String = {
        return String(describing: DateCell.self)
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)
        label.textAlignment = .center

        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("DEINIT DateCell")
    }

    func configure(with date: Date, isSelected: Bool) {

        let df = DateFormatter()
        df.locale = Locale(identifier: "ru_RU")
        df.dateFormat = "dd MMM"
        label.text = df.string(from: date)
        label.font = isSelected ? .boldSystemFont(ofSize: 20) : .systemFont(ofSize: 18)
        label.textColor = isSelected ? .systemBlue : .label
    }
}
