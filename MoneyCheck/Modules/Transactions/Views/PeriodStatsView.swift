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
    func rightButtonTapped(startDate: Date, endDate: Date?)
    func leftButtonTapped(startDate: Date, endDate: Date?)
    func didSelectChart(startDate: Date, endDate: Date)
}


final class PeriodStatsView: UIView {

    // MARK: - UI
    weak var delegate: PeriodStatsViewDelegate?
    private let leftButton = UIButton(type: .system)
    private let rightButton = UIButton(type: .system)
    private let periodButton = UIButton(type: .system)

    private let budgetLabel = AmountLabel()
    private let budgetAmount = AmountLabel()
    private let editButton = UIButton(type: .system)
    private let expenseLabel = AmountLabel()
    private let expenseAmount = AmountLabel()
    private let expensePercentage = AmountLabel()
    private let perDayLabel = AmountLabel()
    private let perDayAmount = AmountLabel()
    private let perDayPercentage = AmountLabel()


    private let bottomContainer = UIView()
    let expenseLabelWalletAmount: AmountLabel = {
        let label = AmountLabel()
        label.textColor = .label
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.text = String(localized: "expenses")
        return label
    }()

    let expenseLabelWallet: AmountLabel = {
        let label = AmountLabel()
        label.textColor = .systemRed
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.text = "100000"
        return label
    }()


    let incomeLabelWalletAmount: AmountLabel = {
        let label = AmountLabel()
        label.textColor = .label
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.text = String(localized: "incomes")
        return label
    }()

    let incomeLabelWallet: AmountLabel = {
        let label = AmountLabel()
        label.textColor = .systemGreen
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.text = "100000"
        return label
    }()

    private lazy var stackViewIncome: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.alignment = .center
        stackView.layer.cornerRadius = 20
        stackView.backgroundColor = .secondarySystemBackground
        stackView.spacing = 4
        stackView.addArrangedSubview(incomeLabelWalletAmount)
        stackView.addArrangedSubview(incomeLabelWallet)
        return stackView
    }()

    private lazy var stackViewExpense: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.alignment = .center
        stackView.layer.cornerRadius = 20
        stackView.backgroundColor = .secondarySystemBackground
        stackView.spacing = 4
        stackView.addArrangedSubview(expenseLabelWalletAmount)
        stackView.addArrangedSubview(expenseLabelWallet)
        return stackView
    }()

    private lazy var stackViewWalletLabels: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.addArrangedSubview(stackViewIncome)
        stackView.addArrangedSubview(stackViewExpense)
        return stackView
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.itemSize = CGSize(width: 50, height: 100)

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
        editButton.setTitle("Edit", for: .normal)

        expenseLabel.text = String(localized: "expense")
        expenseLabel.textAlignment = .center
        expenseAmount.textAlignment = .center
        expensePercentage.textAlignment = .center
        expensePercentage.textColor = .systemGreen

        perDayLabel.text = String(localized: "dayExpense")
        perDayLabel.textAlignment = .center
        perDayAmount.textAlignment = .center
        perDayPercentage.textAlignment = .center

        let statsStack = UIStackView(arrangedSubviews: [budgetLabel, budgetAmount, editButton])
        statsStack.axis = .vertical
        statsStack.distribution = .equalSpacing
        addSubview(statsStack)

        let labelStack = UIStackView(arrangedSubviews: [expenseLabel, expenseAmount, expensePercentage])
        labelStack.axis = .vertical
        labelStack.distribution = .equalSpacing
        addSubview(labelStack)

        let persentageStack = UIStackView(arrangedSubviews: [perDayLabel, perDayAmount, perDayPercentage])
        persentageStack.axis = .vertical
        persentageStack.distribution = .equalSpacing
        addSubview(persentageStack)

        addSubview(collectionView)
        addSubview(stackViewWalletLabels)

        // Layout (SnapKit)
        navStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        labelStack.snp.makeConstraints { make in
            make.top.equalTo(navStack.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }

        statsStack.snp.makeConstraints { make in
            make.top.equalTo(navStack.snp.bottom).offset(8)
            make.leading.equalTo(navStack.snp.leading).inset(16)
        }

        editButton.snp.makeConstraints { make in
            make.height.equalTo(20)
        }

        persentageStack.snp.makeConstraints { make in
            make.top.equalTo(navStack.snp.bottom).offset(8)
            make.trailing.equalTo(navStack.snp.trailing).inset(16)
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(statsStack.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(8)
            make.height.equalTo(100)
        }

        bottomContainer.addSubview(collectionView)
        bottomContainer.addSubview(stackViewWalletLabels)

        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        stackViewWalletLabels.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        addSubview(bottomContainer)

        bottomContainer.snp.makeConstraints { make in
            make.top.equalTo(statsStack.snp.bottom).offset(4)
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
        collectionView.cellForItem(at: IndexPath(row: currentIndex , section: 0))?.isSelected = false
        currentIndex -= 1
        scrollToPeriod(at: currentIndex)
        configure(index: currentIndex)
        delegate?.leftButtonTapped(startDate: charts[currentIndex].startDate, endDate: charts[currentIndex].endDate)
    }

    @objc private func rightButtonTapped() {
        guard currentIndex < charts.count - 1 else { return }
        collectionView.cellForItem(at: IndexPath(row: currentIndex , section: 0))?.isSelected = false
        currentIndex += 1
        scrollToPeriod(at: currentIndex)
        configure(index: currentIndex)
        delegate?.rightButtonTapped(startDate: charts[currentIndex].startDate, endDate: charts[currentIndex].endDate)
    }

    func setTitle(_ title: String) {
        periodButton.setTitle(title, for: .normal)
    }

    func reloadData(_ values: [ChartBarData], date: Date) {
        self.charts = values
        collectionView.reloadData()

        if let index = indexOfCurrentPeriod(in: charts, currentDate: date) {
            configure(index: index)
            scrollToPeriod(at: index)
            currentIndex = index
            collectionView.selectItem(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: [])
        } else {
            configure(index: charts.count - 1)
            scrollToPeriod(at: charts.count - 1)
            currentIndex = charts.count - 1
            collectionView.selectItem(at: IndexPath(row: charts.count - 1, section: 0), animated: false, scrollPosition: [])
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
        collectionView.cellForItem(at: IndexPath(row: currentIndex , section: 0))?.isSelected = false
        scrollToPeriod(at: indexPath.row)
        configure(index: indexPath.row)
        currentIndex = indexPath.row
        delegate?.didSelectChart(startDate: charts[indexPath.row].startDate,
                                 endDate: charts[indexPath.row].endDate)
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
        guard index >= 0 else { return }
        expenseAmount.amountFormatter(charts[index].total, symbol: "SYMBOL")
        perDayAmount.amountFormatter(charts[index].average, symbol: "SYMBOL")

        if let percentage = charts[index].percentage {
            switch charts[index].itemType {
                case .income:
                    if percentage > 0 {
                        expensePercentage.text = "+" + String(format: "%.1f", percentage) + "%"
                        expensePercentage.textColor = .systemGreen

                        let result = charts[index].average - charts[index - 1].average
                        perDayPercentage.textColor = .systemGreen
                        perDayPercentage.amountFormatter(result, sign: "+", symbol: "SYMBOL")
                    } else {
                        expensePercentage.text = String(format: "%.1f", percentage) + "%"
                        expensePercentage.textColor = .systemRed

                        let result = charts[index].average - charts[index - 1].average
                        perDayPercentage.textColor = .systemRed
                        perDayPercentage.amountFormatter(result, sign: "-", symbol: "SYMBOL")
                    }
                case .category, .wallet:
                    if percentage > 0 {
                        expensePercentage.text = "+" + String(format: "%.1f", percentage) + "%"
                        expensePercentage.textColor = .systemRed

                        let result = charts[index].average - charts[index - 1].average
                        perDayPercentage.textColor = .systemRed
                        perDayPercentage.amountFormatter(result, sign: "+", symbol: "SYMBOL")
                    } else {
                        expensePercentage.text = String(format: "%.1f", percentage) + "%"
                        expensePercentage.textColor = .systemGreen

                        let result = charts[index].average - charts[index - 1].average
                        perDayPercentage.textColor = .systemGreen
                        perDayPercentage.amountFormatter(result, sign: "-", symbol: "SYMBOL")
                    }
            }
        } else {
            expensePercentage.text = nil
            perDayPercentage.text = nil
        }

        if let cell = collectionView.cellForItem(at: IndexPath(row: index, section: 0)) {
            cell.isSelected = true
        }
    }

    func indexOfCurrentPeriod(in charts: [ChartBarData], currentDate: Date) -> Int? {
        return charts.firstIndex { chart in
            return currentDate == chart.startDate && currentDate <= chart.endDate
        }
    }

    func updateUI(type: ItemType) {
        if type == .wallet {
            budgetLabel.isHidden = true
            budgetAmount.isHidden = true
            editButton.isHidden = true
            expenseLabel.isHidden = true
            expenseAmount.isHidden = true
            expensePercentage.isHidden = true
            perDayLabel.isHidden = true
            perDayAmount.isHidden = true
            perDayPercentage.isHidden = true
            collectionView.isHidden = true
            stackViewWalletLabels.isHidden = false
        } else if type == .income {
            expenseLabel.text = String(localized: "income")
            budgetLabel.isHidden = false
            budgetAmount.isHidden = false
            editButton.isHidden = false
            expenseLabel.isHidden = false
            expenseAmount.isHidden = false
            expensePercentage.isHidden = false
            perDayLabel.isHidden = false
            perDayAmount.isHidden = false
            perDayPercentage.isHidden = false
            collectionView.isHidden = false
            stackViewWalletLabels.isHidden = true
        } else if type == .category {
            expenseLabel.text = String(localized: "expense")
            budgetLabel.isHidden = false
            budgetAmount.isHidden = false
            editButton.isHidden = false
            expenseLabel.isHidden = false
            expenseAmount.isHidden = false
            expensePercentage.isHidden = false
            perDayLabel.isHidden = false
            perDayAmount.isHidden = false
            perDayPercentage.isHidden = false
            collectionView.isHidden = false
            stackViewWalletLabels.isHidden = true
        }
    }
}
