//
//  PeriodStatsView.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 12.09.2025.
//
import UIKit
import SnapKit

protocol PeriodStatsViewDelegate: AnyObject {
    func periodButtonTapped()
    func rightButtonTapped()
    func leftButtonTapped()
    func didSelectChart(date: Date)
}


final class PeriodStatsView: UIView {

    // MARK: - UI
    weak var delegate: PeriodStatsViewDelegate?
    private let leftButton = UIButton(type: .system)
    private let rightButton = UIButton(type: .system)
    private let periodButton = UIButton(type: .system)

    private let budgetLabel = UILabel()
    private let budgetAmount = UILabel()
    private let expenseLabel = AmountLabel()
    private let expenseAmount = AmountLabel()
    private let perDayLabel = AmountLabel()
    private let perDayAmount = AmountLabel()

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
    private var charts: [ChartBarData] = []
    private var maxValue: Double {
        charts.map { $0.total }.max() ?? 0
    }
    private var currentIndex: Int = 0

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
        leftButton.addTarget(self, action: #selector(leftButtonTapped), for: .touchUpInside)
        rightButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        rightButton.addTarget(self, action: #selector(rightButtonTapped), for: .touchUpInside)

//        periodButton.setTitle("сентябрь 2025", for: .normal)
        periodButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        periodButton.addTarget(self, action: #selector(periodButtonTapped), for: .touchUpInside)

        let navStack = UIStackView(arrangedSubviews: [leftButton, periodButton, rightButton])
        navStack.axis = .horizontal
        navStack.alignment = .center
        navStack.distribution = .equalCentering
        addSubview(navStack)

        // Статистика
        budgetLabel.text = "Бюджет"
        budgetLabel.textAlignment = .center
        budgetAmount.text = "0 ₸"
        budgetAmount.textAlignment = .center

        expenseLabel.text = "Расходы"
        expenseLabel.textAlignment = .center
        expenseAmount.textAlignment = .center

        perDayLabel.text = "В день"
        perDayLabel.textAlignment = .center
        perDayAmount.textAlignment = .center

        let statsStack = UIStackView(arrangedSubviews: [budgetAmount, expenseAmount, perDayAmount])
        statsStack.axis = .horizontal
        statsStack.distribution = .fillEqually
        addSubview(statsStack)

        let labelStack = UIStackView(arrangedSubviews: [budgetLabel, expenseLabel, perDayLabel])
        labelStack.axis = .horizontal
        labelStack.distribution = .fillEqually
        addSubview(labelStack)

        addSubview(collectionView)

        // Layout (SnapKit)
        navStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        labelStack.snp.makeConstraints { make in
            make.top.equalTo(navStack.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        statsStack.snp.makeConstraints { make in
            make.top.equalTo(labelStack.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(statsStack.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(8)
            make.height.equalTo(100)
        }
    }

    @objc func periodButtonTapped() {
        delegate?.periodButtonTapped()
    }

    @objc private func leftButtonTapped() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        scrollToPeriod(at: currentIndex)
        delegate?.leftButtonTapped()
    }

    @objc private func rightButtonTapped() {
        guard currentIndex < charts.count - 1 else { return }
        currentIndex += 1
        scrollToPeriod(at: currentIndex)
        delegate?.rightButtonTapped()
    }

    func setTitle(_ title: String) {
        periodButton.setTitle(title, for: .normal)
    }

    func reloadData(_ values: [ChartBarData], date: Date, period: PeriodType) {
        self.charts = values
        collectionView.reloadData()

        if let index = indexOfCurrentPeriod(in: charts, currentDate: date, period: period) {
            scrollToPeriod(at: index)
            configure(index: index)
        }
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension PeriodStatsView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        charts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChartCell.identifier, for: indexPath) as? ChartCell else { return  UICollectionViewCell() }
        let value = charts[indexPath.row]
        cell.configure(value, k: maxValue)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        scrollToPeriod(at: indexPath.row)
        configure(index: indexPath.row)
        currentIndex = indexPath.row
        delegate?.didSelectChart(date: charts[indexPath.row].date)
    }

    func scrollToPeriod(at index: Int) {
        guard index < charts.count else { return }
        collectionView.scrollToItem(
            at: IndexPath(item: index, section: 0),
            at: .right,   // можно .left или .right
            animated: true
        )
    }

    func configure(index: Int) {
        expenseAmount.amountFormatter(charts[index].total)
        perDayAmount.amountFormatter(charts[index].average)
    }

    func indexOfCurrentPeriod(in charts: [ChartBarData], currentDate: Date, period: PeriodType) -> Int? {
        switch period {
        case .week:
            return charts.firstIndex { chart in
                Calendar.current.isDate(chart.date, equalTo: currentDate, toGranularity: .weekOfYear)
            }

        case .month:
            return charts.firstIndex { chart in
                Calendar.current.isDate(chart.date, equalTo: currentDate, toGranularity: .month)
            }

        case .custom(let start, _):
            return charts.firstIndex { chart in
                Calendar.current.isDate(chart.date, equalTo: start, toGranularity: .day)
            }

        default:
            return nil
        }
    }
}
