import UIKit
import Combine
import SnapKit
import SwiftUI

final class TransactionsAnalyticsViewController: UIViewController {

    private let periodButton = UIBarButtonItem()

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
        let tableView = UITableView(frame: .zero, style: .plain)
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.bindPeriod()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.updateTableHeaderHeight()
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
                .sink { [weak self] _ in
                    self?.updateTableHeaderHeight()
                }
                .store(in: &cancellables)
        viewModel.$sections
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    self?.tableView.reloadData()
                }
                .store(in: &cancellables)
        viewModel.$selectedPeriod
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedPeriod in
                self?.periodButton.title = switch selectedPeriod {
                    case .custom(let from, let to): "\(from.periodName) - \(to.periodName)"
                    default: selectedPeriod.displayTitle
                }
//                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }

    private func updateTableHeaderHeight() {
        guard let headerView = tableView.tableHeaderView else { return }

        // Форсируем layout SwiftUI
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()

        // Вычисляем корректную высоту
        let targetSize = headerView.systemLayoutSizeFitting(
            CGSize(
                width: tableView.bounds.width,
                height: UIView.layoutFittingCompressedSize.height
            ),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )

        // Обновляем frame
        if headerView.frame.height != targetSize.height {
            var frame = headerView.frame
            frame.size.height = targetSize.height
            headerView.frame = frame

            tableView.tableHeaderView = headerView
        }
    }


    private func setupUI() {
        title = String(localized: "analytics")
        view.backgroundColor = .systemBackground

        periodButton.title = viewModel.selectedPeriod.displayTitle
        periodButton.target = self
        periodButton.action = #selector(handlePeriodButtonTapped)
        self.navigationItem.rightBarButtonItem = periodButton
        self.navigationItem.rightBarButtonItem?.tintColor = .label

        tableView.showsVerticalScrollIndicator = false
        tableView.register(TransactionCell.self, forCellReuseIdentifier: TransactionCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self

        // Оборачиваем SwiftUI view в hostingController
        let hostingController = UIHostingController(rootView: donutView)
        addChild(hostingController)
        hostingController.didMove(toParent: self)

        // Минимальная высота для рендера
        hostingController.view.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 1)
        tableView.tableHeaderView = hostingController.view

        // Форсируем layout и пересчитываем размер
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()

        let targetSize = hostingController.sizeThatFits(in: CGSize(width: view.bounds.width, height: UIView.layoutFittingCompressedSize.height))

        // Устанавливаем frame с нужной высотой
        hostingController.view.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: targetSize.height)
        tableView.tableHeaderView = hostingController.view

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }

    @objc private func handlePeriodButtonTapped() {
        viewModel.showSelectPeriod()
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
        return 60
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
//        viewModel.showEditTransaction(for: transaction) 
    }
}
