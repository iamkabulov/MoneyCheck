//
//  ContactUsButton.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 13.01.2026.
//


import UIKit

public struct ContactModel {
    public let title: String
    public let type: ContactType
    public let image: UIImage
    public let url: URL?

    public init(from type: ContactType) {
        self.type = type

        switch type {
        case .telegram:
            self.title = String(localized: "Telegram")
            self.image = UIImage(named: "telegram.icon") ?? UIImage()
            self.url = URL(string: "https://t.me/iamkabulov")
        case .whatsapp:
            self.title = String(localized: "Whatsapp")
            self.image = UIImage(named: "whatsapp.icon") ?? UIImage()
            self.url = URL(string: "https://wa.me/77073235846")
        case .email:
            self.title = String(localized: "Email")
                self.image = UIImage(named: "email.icon") ?? UIImage()
            self.url = URL(string: "iamkabulov@gmail.com")
        }
    }
}


class ContactUsButton: UIButton {

    enum Constants {
        static let cornerRadius: CGFloat = 10
        static let height: CGFloat = 50

        enum Spacing {
            static let small: CGFloat = 8
            static let medium: CGFloat = 16
            static let large: CGFloat = 24
        }

        enum ImageSize {
            static let width: CGFloat = 12
            static let height: CGFloat = 24
        }
    }

    var model: ContactModel?

    private let iconImageView = UIImageView()
    private let buttonTitle = UILabel()
    private let chevronImageView = UIImageView()

    init(model: ContactModel) {
        super.init(frame: .zero)
        self.model = model
        self.configure(model: model)
        self.setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupViews() {

        self.backgroundColor = .secondarySystemBackground
        self.layer.cornerRadius = Constants.cornerRadius
        self.heightAnchor.constraint(equalToConstant: Constants.height).isActive = true


        iconImageView.contentMode = .scaleAspectFit
        buttonTitle.font = UIFont.preferredFont(forTextStyle: .headline)
        buttonTitle.textColor = .label

        addSubview(iconImageView)
        addSubview(buttonTitle)
        addSubview(chevronImageView)

        iconImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(Constants.Spacing.medium)
            make.width.height.equalTo(Constants.ImageSize.height)
        }

        buttonTitle.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(iconImageView.snp.trailing).offset(Constants.Spacing.medium)
        }

        chevronImageView.tintColor = .secondaryLabel
        if let image = UIImage(systemName: "chevron.right") {
            let largeConfig = UIImage.SymbolConfiguration(pointSize: Constants.ImageSize.width, weight: .bold, scale: .large)
            chevronImageView.image = image.withConfiguration(largeConfig)
        }

        chevronImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(Constants.Spacing.medium)
        }
    }

    func configure(model: ContactModel) {
        buttonTitle.text = model.title
        iconImageView.image = model.image.withRenderingMode(.alwaysOriginal).withTintColor(.white)
    }
}
