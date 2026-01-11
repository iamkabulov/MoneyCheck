//
//  SettingsViewProtocol.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 07.01.2026.
//


import UIKit
import SnapKit
import Combine

protocol SettingsViewProtocol: AnyObject {
    func configure(with model: SettingsViewModelEntity)
}

public class SettingsViewController: UIViewController {

    enum Constants {
        static let zero: CGFloat = 0
        static let smallSpacing: CGFloat = 4
        static let mediumSpacing: CGFloat = 8
        static let largeSpacing: CGFloat = 16
        static let extraLargeSpacing: CGFloat = 24
        static let cornerRadius: CGFloat = 32
        enum Size {
            static let small: CGFloat = 20
            static let medium: CGFloat = 32
            static let large: CGFloat = 40
            static let extraLarge: CGFloat = 50
        }
    }

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
//        tableView.backgroundColor = UIColor(red: 30/255, green: 30/255, blue: 29/255, alpha: 1.0)
        tableView.rowHeight = Constants.Size.extraLarge
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return tableView
    }()
    private lazy var versionLabel = createFooterLabel()
    private lazy var userIdLabel = createFooterLabel()
    private var sections = [SettingsOptionSection]()
    private var viewModel: SettingsViewModel
    private var cancellables = Set<AnyCancellable>()
    var onToggle: ((Bool) -> Void)?

    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setupBindings()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupStyle()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    deinit {
    }

    private func setupBindings() {
        viewModel.$settingsViewModelEntity
            .receive(on: DispatchQueue.main)
            .sink { [weak self] model in
                guard let self = self else { return }
                self.title = model?.title
                self.sections = model?.options ?? []
                self.versionLabel.text = model?.appVersion
                self.userIdLabel.text = model?.userId

                self.tableView.reloadData()
            }
            .store(in: &cancellables)
        viewModel.$reminder
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
}

// MARK: - SettingsView Style Setup
private extension SettingsViewController {
    func setupStyle() {
//        view.backgroundColor = UIColor(red: 30/255, green: 30/255, blue: 29/255, alpha: 1.0)
        tableView.separatorStyle = .none
    }

    func setupTableView() {
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }

        
    }

    func configureCell(cell: UITableViewCell, title: String, icon: String, type: SettingsOptionType? = nil) {

        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
//        cell.backgroundColor = UIColor(red: 30/255, green: 30/255, blue: 29/255, alpha: 1.0)
        let iconContainerView = UIView()
        iconContainerView.backgroundColor = .secondarySystemGroupedBackground
        iconContainerView.layer.cornerRadius = 8
        iconContainerView.layer.borderWidth = 1
        iconContainerView.layer.borderColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0).cgColor

        let iconImageView = UIImageView()
        iconImageView.image = UIImage(systemName: icon)?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 12))
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .label

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16)
        titleLabel.textColor = .label

        let bodyLabel = UILabel()
        bodyLabel.text = title
        bodyLabel.font = .systemFont(ofSize: 10)
        bodyLabel.textColor = .secondaryLabel

        let toggleSwitch = UISwitch()

        iconContainerView.addSubview(iconImageView)
        cell.contentView.addSubview(iconContainerView)


        if type == .toggle(isOn: false) || type == .toggle(isOn: true) {
            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.font = .systemFont(ofSize: 16)
            titleLabel.textColor = .label

            let bodyLabel = UILabel()
            bodyLabel.text = title
            bodyLabel.font = .systemFont(ofSize: 10)
            bodyLabel.textColor = .secondaryLabel
            bodyLabel.text = viewModel.reminderSubtitle

            let stackView = UIStackView(arrangedSubviews: [titleLabel, bodyLabel])
            stackView.axis = .vertical
            stackView.spacing = 2
            cell.contentView.addSubview(stackView)
            cell.contentView.addSubview(toggleSwitch)

            stackView.snp.makeConstraints { make in
                make.leading.equalTo(iconContainerView.snp.trailing).offset(Constants.mediumSpacing)
                make.trailing.equalToSuperview().offset(-Constants.mediumSpacing)
                make.centerY.equalToSuperview()
            }

            toggleSwitch.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.trailing.equalToSuperview().offset(-Constants.mediumSpacing)
            }

            toggleSwitch.isOn = viewModel.reminder?.isEnabled ?? false

            toggleSwitch.addAction(
                UIAction { [weak self] action in
                    guard let self = self,
                          let toggle = action.sender as? UISwitch else { return }

                    self.viewModel.setReminderEnabled(toggle.isOn)
                },
                for: .valueChanged
            )

        } else {
            // Non-toggle cell
            cell.contentView.addSubview(titleLabel)
            titleLabel.snp.makeConstraints { make in
                make.leading.equalTo(iconContainerView.snp.trailing).offset(Constants.mediumSpacing)
                make.trailing.equalToSuperview().offset(-Constants.mediumSpacing)
                make.centerY.equalToSuperview()
            }
        }


        iconContainerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Constants.largeSpacing)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(Constants.Size.medium)
        }

        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.width.equalTo(Constants.Size.small)
        }
    }

    func createFooterLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.textAlignment = .right
        label.textColor = .tertiaryLabel
        return label
    }
}

// MARK: - UITableViewDelegate
extension SettingsViewController: UITableViewDelegate {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].options.count
    }

    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 1 {
            let footerView = UIStackView(
                arrangedSubviews: [versionLabel, userIdLabel]
            )
            footerView.axis = .vertical
            footerView.distribution = .fillEqually
            footerView.spacing = Constants.smallSpacing

            footerView.isLayoutMarginsRelativeArrangement = true
            footerView.layoutMargins = UIEdgeInsets(
                top: Constants.mediumSpacing,
                left: Constants.zero,
                bottom: Constants.zero,
                right: Constants.mediumSpacing
            )
            return footerView
        } else {
            return nil
        }
    }

    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1 {
            return Constants.Size.large
        } else {
            return Constants.zero
        }
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.didTapOnSettingsOption(option:sections[indexPath.section].options[indexPath.row].option)
    }
}

// MARK: - UITableViewDataSource
extension SettingsViewController: UITableViewDataSource {

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "Cell",
            for: indexPath
        )
        let option = sections[indexPath.section].options[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        configureCell(
            cell: cell,
            title: option.title,
            icon: option.icon,
            type: option.type
        )
        return cell
    }

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
}

// MARK: - SettingsViewProtocol
//extension SettingsViewController: SettingsViewProtocol {
//    public func configure(with model: SettingsViewModelEntity) {
//        title = model.title
//        sections = model.options
//        versionLabel.text = model.appVersion
//        userIdLabel.text = model.userId
//    }
//}
