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
        contentView.addSubview(monthLabel)
        
        barView.backgroundColor = .darkGray
        barView.layer.cornerRadius = 4
        
        monthLabel.textAlignment = .center
        monthLabel.font = .systemFont(ofSize: 12)
        monthLabel.textColor = .lightGray
        
        barView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalTo(20)
            make.height.equalTo(40) // базово, потом можно скейлить
        }
        
        monthLabel.snp.makeConstraints { make in
            make.top.equalTo(barView.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    func configure(month: String, value: CGFloat) {
        monthLabel.text = month
        let scaledHeight = max(10, min(80, value)) // нормируем высоту
        barView.snp.updateConstraints { make in
            make.height.equalTo(scaledHeight)
        }
    }
}
