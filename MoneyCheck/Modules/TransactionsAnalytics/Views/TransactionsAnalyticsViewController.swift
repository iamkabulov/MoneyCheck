import UIKit
import Combine
import SnapKit
import SwiftUI

final class TransactionsAnalyticsViewController: UIViewController {

    private lazy var hostingController = UIHostingController(rootView: donutView)
    @Published var items: [DonutChartItem] = []
    private let viewModel: TransactionsAnalyticsViewModel
    private var cancellables = Set<AnyCancellable>()
    private lazy var donutView = DonutChartView(
        viewModel: self.viewModel,
        onLegendTap: { [weak self] item in
            self?.handleLegendTap(item)
        }
    )

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .none
        tableView.register(TransactionCell.self, forCellReuseIdentifier: TransactionCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()

    init(viewModel: TransactionsAnalyticsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.bindViewModel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    deinit {
        print("TransactionsAnalyticsViewController deinit")
    }

    private func bindViewModel() {
        viewModel.$chartDonutItems
                .receive(on: DispatchQueue.main)
                .assign(to: \.self.items, on: self)
                .store(in: &cancellables)
        viewModel.$sections
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    self?.tableView.reloadData()
                }
                .store(in: &cancellables)
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        tableView.showsVerticalScrollIndicator = false
        addChild(hostingController)
        view.addSubview(hostingController.view)
        view.addSubview(tableView)
        hostingController.didMove(toParent: self)

        // 5️⃣ Autolayout

        hostingController.view.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(hostingController.view.snp.bottom).offset(16)
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }

    }

    private func handleLegendTap(_ item: DonutChartItem) {
        print("Tapped legend:", item.title)

        // варианты:
        // • открыть список транзакций
        // • отфильтровать таблицу
        // • подсветить сектор
        // • показать BottomSheet
    }

    private func formatAmount(_ amount: Double) -> String {
        let formattedAmount = Double.amountFormatter(amount)
        let sign = amount >= 0 ? "+" : "-"
        return "\(sign)\(formattedAmount) ₸"
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
}

extension TransactionsAnalyticsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
//        viewModel.sections.count == 0 ? showEmptyView(false) : showEmptyView(true)
        return viewModel.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sections[section].transactions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as? TransactionCell else { return UITableViewCell() }
        let transaction = viewModel.sections[indexPath.section].transactions[indexPath.row]
        cell.configure(with: transaction, currentWalletId: UUID())
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear

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
//        viewModel.showEditTransaction(for: transaction) 
    }
}
