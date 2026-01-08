import UIKit
import PanModal
import Combine
import SnapKit

final class TransactionsViewController: UIViewController {
    private let viewModel: TransactionsViewModel
    private var cancellables = Set<AnyCancellable>()

    private lazy var stats = PeriodStatsView()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .none
        tableView.register(TransactionCell.self, forCellReuseIdentifier: TransactionCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()

    private let editButton = UIBarButtonItem()

    private lazy var emptyView: EmptyView = {
        let view = EmptyView()
        view.isHidden = true
        return view
    }()

    init(viewModel: TransactionsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        bindViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("deinit TransactionsViewController")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        title = String(localized: "transactions")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(stats)
        view.addSubview(tableView)
        view.addSubview(emptyView)
        stats.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
        }
        stats.delegate = self

        tableView.snp.makeConstraints { make in
            make.top.equalTo(stats.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
        }

        emptyView.snp.makeConstraints { make in
            make.centerX.equalTo(tableView.snp.centerX)
            make.centerY.equalTo(tableView.snp.centerY)
        }

        editButton.title = String(localized: "edit")
        self.editButton.target = self
        self.editButton.action = #selector(openEditItemViewController)
        self.navigationItem.rightBarButtonItem = editButton
        self.navigationItem.rightBarButtonItem?.tintColor = .label


    }
    
    private func bindViewModel() {
        viewModel.$sections
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sections in
                print("\(sections.count)")
                self?.tableView.reloadData()
                self?.stats.expenseLabelWallet.amountFormatter(sections.reduce(0) { partialResult, transaction in
                        partialResult + transaction.expenseAmount
                }, sign: "-", symbol: "SYMBOL")
                self?.stats.incomeLabelWallet.amountFormatter(sections.reduce(0) { partialResult, transaction in
                        partialResult + transaction.incomeAmount
                }, sign: "+", symbol: "SYMBOL")
            }
            .store(in: &cancellables)
        viewModel.$periodTitle
            .receive(on: DispatchQueue.main)
            .sink { [weak self] title in
                self?.stats.setTitle(title)
            }
            .store(in: &cancellables)
        viewModel.$barCharts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] values in
                guard let self = self else { return }
                self.stats.reloadData(values, date: self.viewModel.currentDate)
                self.stats.updateUI(type: viewModel.itemType)
            }
            .store(in: &cancellables)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
    
    private func formatAmount(_ amount: Double) -> String {
        let formattedAmount = Double.amountFormatter(amount)
        let sign = amount >= 0 ? "+" : "-"
        return "\(sign)\(formattedAmount) ₸"
    }

    @objc func openEditItemViewController() {
        self.viewModel.showEditItemView(id: viewModel.itemId, itemType: viewModel.itemType)
    }

    private func showEmptyView(_ value: Bool) {
        emptyView.isHidden = value
    }
}

extension TransactionsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.sections.count == 0 ? showEmptyView(false) : showEmptyView(true)
        return viewModel.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sections[section].transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as? TransactionCell else { return UITableViewCell() }
        let transaction = viewModel.sections[indexPath.section].transactions[indexPath.row]
        cell.configure(with: transaction, currentWalletId: viewModel.itemId)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .systemBackground
        
        let section = viewModel.sections[section]
        
        let dateLabel = UILabel()
        dateLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        dateLabel.text = formatDate(section.date)
        
        let amountLabel = AmountLabel()
        amountLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        amountLabel.text = formatAmount(section.totalAmount)
        amountLabel.textAlignment = .right
        
        if section.totalAmount > 0 {
            amountLabel.textColor = .systemGreen
        } else if section.totalAmount < 0 {
            amountLabel.textColor = .systemRed
        } else {
            amountLabel.textColor = .label
        }
        
        headerView.addSubview(dateLabel)
        headerView.addSubview(amountLabel)
        
        dateLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(8)
            make.trailing.equalTo(headerView.snp.centerX)
            make.centerY.equalToSuperview()
        }
        
        amountLabel.snp.makeConstraints { make in
            make.leading.equalTo(dateLabel.snp.trailing).offset(8)
            make.trailing.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let transaction = viewModel.sections[indexPath.section].transactions[indexPath.row]
        viewModel.showEditTransaction(for: transaction)
    }
}

extension TransactionsViewController: PeriodStatsViewDelegate {
    func rightButtonTapped(startDate: Date, endDate: Date?) {
        self.viewModel.currentDate = startDate
        self.viewModel.loadTransactions(endDate: endDate)
    }

    func leftButtonTapped(startDate: Date, endDate: Date?) {
        self.viewModel.currentDate = startDate
        self.viewModel.loadTransactions(endDate: endDate)
    }

    func periodButtonTapped() {
        self.viewModel.openSelectPeriod()
    }

    func didSelectChart(startDate: Date, endDate: Date) {
        self.viewModel.currentDate = startDate
        self.viewModel.loadTransactions(endDate: endDate)
    }
}
