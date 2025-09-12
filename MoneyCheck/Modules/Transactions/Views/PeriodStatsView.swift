//
//  PeriodStatsView.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 12.09.2025.
//
import UIKit
import SnapKit


final class PeriodStatsView: UIView {

    // MARK: - UI

    private let leftButton = UIButton(type: .system)
    private let rightButton = UIButton(type: .system)
    private let periodButton = UIButton(type: .system)

    private let budgetLabel = UILabel()
    private let expenseLabel = UILabel()
    private let perDayLabel = UILabel()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.itemSize = CGSize(width: 50, height: 80)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.dataSource = self
        cv.delegate = self
        cv.register(ChartCell.self, forCellWithReuseIdentifier: ChartCell.identifier)
        return cv
    }()

    // MARK: - Data
    private var months: [String] = [
        "янв.", "фев.", "март", "апр.", "май", "июнь",
        "июль", "авг.", "сент.", "окт.", "ноя.", "дек."
    ]

    private var values: [CGFloat] = [] // тут можно хранить расходы

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .systemBackground

        // Навигация
        leftButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        rightButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)

        periodButton.setTitle("сентябрь 2025", for: .normal)
        periodButton.titleLabel?.font = .boldSystemFont(ofSize: 18)

        let navStack = UIStackView(arrangedSubviews: [leftButton, periodButton, rightButton])
        navStack.axis = .horizontal
        navStack.alignment = .center
        navStack.distribution = .equalCentering
        addSubview(navStack)

        // Статистика
        budgetLabel.text = "Бюджет\n0 ₸"
        budgetLabel.numberOfLines = 2
        budgetLabel.textAlignment = .center

        expenseLabel.text = "Расход\n56 ₸\n-98,79%"
        expenseLabel.numberOfLines = 3
        expenseLabel.textAlignment = .center

        perDayLabel.text = "В день\n4,67 ₸\n-144,98 ₸"
        perDayLabel.numberOfLines = 3
        perDayLabel.textAlignment = .center

        let statsStack = UIStackView(arrangedSubviews: [budgetLabel, expenseLabel, perDayLabel])
        statsStack.axis = .horizontal
        statsStack.distribution = .fillEqually
        addSubview(statsStack)

        addSubview(collectionView)

        // Layout (SnapKit)
        navStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        statsStack.snp.makeConstraints { make in
            make.top.equalTo(navStack.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(statsStack.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(8)
            make.height.equalTo(100)
        }
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension PeriodStatsView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        months.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChartCell.identifier, for: indexPath) as! ChartCell
        let value = values.indices.contains(indexPath.item) ? values[indexPath.item] : 0
        cell.configure(month: months[indexPath.item], value: value)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Выбран месяц: \(months[indexPath.item])")
        // Тут можно дернуть делегат или замыкание, чтобы обновить период
    }
}
