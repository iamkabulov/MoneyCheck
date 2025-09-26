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

    private var currentValue: ChartBarData?
    private var currentK: Double?
    private var barHeightConstraint: Constraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        currentValue = nil
        currentK = nil
        monthLabel.text = nil
        // сброс высоты (чтобы при повторном использовании не было артефактов)
        barHeightConstraint?.update(offset: 0)
    }

    private func setupUI() {
        contentView.addSubview(monthLabel)
        contentView.addSubview(barView)
        barView.addSubview(barViewFilled)

        // внешний вид
        barView.backgroundColor = .lightGray
        barView.layer.cornerRadius = 4
        barView.clipsToBounds = true

        barViewFilled.backgroundColor = .systemGreen
        barViewFilled.layer.cornerRadius = 4
        barViewFilled.clipsToBounds = true

        monthLabel.textAlignment = .center
        monthLabel.font = .systemFont(ofSize: 12)
        monthLabel.textColor = .lightGray

        // layout
        monthLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(4)   // <- исправлено: inset, а не offset
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(16)
        }

        barView.snp.makeConstraints { make in
            make.bottom.equalTo(monthLabel.snp.top).offset(-6)
            make.centerX.equalToSuperview()
            make.width.equalTo(20)
            make.top.equalToSuperview().offset(6)
        }

        barViewFilled.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            // сохраняем constraint, чтобы потом обновлять его
            barHeightConstraint = make.height.equalTo(0).constraint
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // layoutSubviews вызывается, когда у barView уже корректный bounds
        // если у нас есть данные — пересчитаем высоту и обновим constraint
        guard let value = currentValue, let k = currentK else { return }

        let maxHeight = barView.bounds.height
        if maxHeight <= 0 { return } // если всё ещё 0 — ничего не делаем

        let ratio = k > 0 ? value.total / k : 0
        let target = max(0, min(maxHeight, ratio * maxHeight))

        // обновляем только если сильно отличается, чтобы избежать лишних layout
        let currentConst = barHeightConstraint?.layoutConstraints.first?.constant ?? 0
        if abs(currentConst - target) > 0.5 {
            barHeightConstraint?.update(offset: target)
            // анимируем изменение высоты
            UIView.animate(withDuration: 0.22) {
                self.layoutIfNeeded()
            }
        }
    }

    // PUBLIC
    func configure(_ value: ChartBarData, k: Double, animated: Bool = true) {
        currentValue = value
        currentK = k
        monthLabel.text = value.title

        // пробуем посчитать и применить сразу — если layout уже готов
        contentView.layoutIfNeeded()
        let maxHeight = barView.bounds.height

        let applyHeight: (CGFloat) -> Void = { [weak self] target in
            guard let self = self else { return }
            self.barHeightConstraint?.update(offset: target)
            if animated {
                UIView.animate(withDuration: 0.22) {
                    self.layoutIfNeeded()
                }
            } else {
                self.layoutIfNeeded()
            }
        }

        if maxHeight > 0 {
            let ratio = k > 0 ? value.total / k : 0
            let target = max(0, min(maxHeight, ratio * maxHeight))
            applyHeight(target)
        } else {
            // layout ещё не готов — отложим на следующий цикл, тогда layoutSubviews тоже может сработать
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.contentView.layoutIfNeeded()
                let mh = self.barView.bounds.height
                let ratio = k > 0 ? value.total / k : 0
                let t = max(0, min(mh, ratio * mh))
                applyHeight(t)
            }
        }
    }
}
