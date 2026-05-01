//
//  CurrencySelectorViewController.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 08.01.2026.
//

import UIKit
import Combine

final class CurrencySelectorViewController: UIViewController {

    // MARK: - Public
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Private
    private let viewModel: CurrencySelectorViewModel

    // MARK: - UI
    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = String(localized: "Search currency")
        return sc
    }()

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tv.dataSource = self
        tv.delegate = self
        return tv
    }()

    // MARK: - Init
    init(
        viewModel: CurrencySelectorViewModel
    ) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.bindings()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("Deinited CurrencySelectorViewController")
    }


    func bindings() {
        viewModel.$selectedCurrency
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - Setup
    private func setupUI() {
        title = String(localized: "Currency")
        view.backgroundColor = .systemBackground

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension CurrencySelectorViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.filteredCurrencies.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let currency = viewModel.filteredCurrencies[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        var content = cell.defaultContentConfiguration()
        content.text = "\(currency.symbol)  \(currency.code)"
        content.secondaryText = currency.name
        cell.contentConfiguration = content

        cell.accessoryType = (currency.symbol == viewModel.selectedCurrency.symbol) ? .checkmark : .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currency = viewModel.filteredCurrencies[indexPath.row]
        viewModel.selectCurrency(currency)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension CurrencySelectorViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.filter(searchController.searchBar.text ?? "")
        tableView.reloadData()
    }
}
