//
//  ContactUsViewProtocol.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 13.01.2026.
//


import UIKit
import SnapKit
import PanModal
import Combine

public class ContactUsBottomSheetViewController: UIViewController, PanModalPresentable {

    private var cancellables = Set<AnyCancellable>()

    enum Constants {
        static let cornerRadius: CGFloat = 10

        enum Spacing {
            static let small: CGFloat = 8
            static let medium: CGFloat = 16
            static let large: CGFloat = 24
        }

        enum ImageSize {
            static let width: CGFloat = 24
            static let height: CGFloat = 24
        }
    }

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 24
        view.layer.cornerCurve = .continuous
        return view
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [])
        stackView.axis = .vertical
        stackView.spacing = Constants.Spacing.small
        return stackView
    }()

    private lazy var bottomSheetTitle: UILabel = {
        let label = UILabel()
        label.text = String(localized: "Contact via")
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()

    private let closeButton: UIButton = {
        let button = UIButton()
        if let image = UIImage(systemName: "xmark.circle.fill") {
            let largeConfig = UIImage.SymbolConfiguration(pointSize: Constants.ImageSize.width, weight: .light, scale: .medium)
            button.setImage(image.withConfiguration(largeConfig), for: .normal)
        }
        button.tintColor = .darkGray
        return button
    }()

    private let viewModel: ContactUsViewModel

    init(viewModel: ContactUsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.bind()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind() {
        viewModel.$model
            .receive(on: DispatchQueue.main)
            .sink { [weak self] model in
                self?.configure(with: model)
            }
            .store(in: &cancellables)
    }

    public var panScrollable: UIScrollView? {
        nil
    }
    
    public var shortFormHeight: PanModalHeight {
        .contentHeight(UIScreen.main.bounds.height / 3)
    }
    
    public var longFormHeight: PanModalHeight {
        shortFormHeight
    }

    public var showDragIndicator: Bool {
        false
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupStyle()
    }
}

// MARK: - ContactUsView Style Setup
private extension ContactUsBottomSheetViewController {
    func setupStyle() {
        view.backgroundColor = .clear
        view.layer.cornerRadius = Constants.cornerRadius
        view.layer.masksToBounds = true
    }

    func setupLayout() {
        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
        }
        
        containerView.addSubview(bottomSheetTitle)
        containerView.addSubview(stackView)

        bottomSheetTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Constants.Spacing.medium)
            make.leading.trailing.equalToSuperview().inset(Constants.Spacing.medium)
        }
  
        stackView.snp.makeConstraints { make in
            make.top.equalTo(bottomSheetTitle.snp.bottom).offset(Constants.Spacing.large)
            make.leading.trailing.equalToSuperview().inset(Constants.Spacing.medium)
            make.bottom.lessThanOrEqualToSuperview().inset(Constants.Spacing.medium)
        }
    }

    @objc func didTapButton(_ sender: ContactUsButton) {
        guard let model = sender.model else { return }
        viewModel.didTapButton(model: model)
//        switch sender.model?.type {
//        case .telegram:
////            presenter.didTapTelegram(url: sender.model?.url)
//        case .whatsapp:
////            presenter.didTapWhatsapp(url: sender.model?.url)
//        case .email:
////            presenter.didTapEmail(url: sender.model?.url)
//        default:
//            break
//        }
    }

    @objc private func dismissBottomSheet() {
//        presenter.didTapClose()
    }
}

extension ContactUsBottomSheetViewController {
    public func configure(with models: [ContactModel]) {
        models.forEach { model in
            let button = ContactUsButton(model: model)
            button.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
    }
}
