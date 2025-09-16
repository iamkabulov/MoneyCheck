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
        contentView.addSubview(barView)
        contentView.addSubview(barViewFilled)
        contentView.addSubview(monthLabel)

        barView.backgroundColor = .lightGray
        barView.layer.cornerRadius = 4

        barViewFilled.backgroundColor = .darkGray
//        barViewFilled.layer.cornerRadius = 4
        
        monthLabel.textAlignment = .center
        monthLabel.font = .systemFont(ofSize: 12)
        monthLabel.textColor = .lightGray

        barView.snp.makeConstraints { make in
            make.bottom.equalTo(monthLabel.snp.top).offset(-4)
            make.centerX.equalToSuperview()
            make.width.equalTo(20)
            make.top.equalToSuperview()
        }

        barViewFilled.snp.makeConstraints { make in
            make.bottom.equalTo(monthLabel.snp.top).offset(-4)
            make.centerX.equalToSuperview() // базово, потом можно скейлить
            make.width.equalTo(20)
            make.height.equalTo(40)
        }
        
        monthLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(4)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    func configure(_ value: ChartBarData) {
        //TODO: - сделать относительно максимума или предыдущего месяца
        monthLabel.text = value.title
        let scaledHeight = max(0, min(60, value.total))  ////нормируем высоту нужно подумать
        barViewFilled.snp.updateConstraints { make in
            make.height.equalTo(scaledHeight)
        }
    }
}
