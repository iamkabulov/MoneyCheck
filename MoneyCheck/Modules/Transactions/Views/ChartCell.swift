//
//  ChartCell.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 12.09.2025.
//
import UIKit
import SnapKit

final class ChartCell: UICollectionViewCell {
    static let identifier = String(describing: ChartCell.self)

    private let barView = UIView()
    private let barViewFilled = UIView()
    private let monthLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(monthLabel)
        contentView.addSubview(barView)
        barView.addSubview(barViewFilled)

        barView.backgroundColor = .lightGray
        barView.layer.cornerRadius = 4

        barViewFilled.backgroundColor = .systemGreen
        barViewFilled.layer.cornerRadius = 4
        
        monthLabel.textAlignment = .center
        monthLabel.font = .systemFont(ofSize: 12)
        monthLabel.textColor = .lightGray

        monthLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(4)
            make.leading.trailing.equalToSuperview()
        }

        barView.snp.makeConstraints { make in
            make.bottom.equalTo(monthLabel.snp.top).offset(-4)
            make.centerX.equalToSuperview()
            make.width.equalTo(20)
            make.top.equalToSuperview()
        }

        barViewFilled.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(0)
        }
    }
    
    func configure(_ value: ChartBarData, k: Double) {
        monthLabel.text = value.title

        let maxHeight = barView.layer.bounds.height

        // нормируем
        let ratio = k > 0 ? value.total / k : 0
        let scaledHeight = max(0, min(maxHeight, ratio * maxHeight))

        barViewFilled.snp.updateConstraints { make in
            make.height.equalTo(scaledHeight)
        }
    }
}
