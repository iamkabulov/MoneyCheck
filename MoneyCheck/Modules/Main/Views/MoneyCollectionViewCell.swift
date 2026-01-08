import UIKit
import SnapKit

final class MoneyCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: MoneyCollectionViewCell.self)
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        return view
    }()

    let iconContainerView: UIView = {
        let view = UIView()
        view.isOpaque = false
        view.layer.cornerRadius = 24
        return view
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.preferredSymbolConfiguration = .init(pointSize: 20, weight: .regular)
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let amountLabel: AmountLabel = {
        let label = AmountLabel()
        label.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75
        return label
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    func configure(
        name: String,
        amount: Double?,
        icon: String,
        color: String,
        currency: String
    ) {
        if name.isEmpty {
            nameLabel.isHidden = true
            amountLabel.isHidden = true
            iconContainerView.snp.remakeConstraints { make in
                make.center.equalToSuperview()
                make.size.equalTo(48)
            }
        } else {
            nameLabel.isHidden = false
            amountLabel.isHidden = (amount == nil)
            
            iconContainerView.snp.remakeConstraints { make in
                make.centerX.centerY.equalToSuperview()
                make.size.equalTo(48)
            }

            nameLabel.snp.remakeConstraints { make in
                make.bottom.equalTo(iconContainerView.snp.top).offset(-4)
                make.leading.trailing.equalToSuperview()
            }

            if amount == nil {
                amountLabel.snp.remakeConstraints { make in
                    make.height.equalTo(0)
                }
            } else {
                amountLabel.snp.remakeConstraints { make in
                    make.top.equalTo(iconContainerView.snp.bottom).offset(4)
                    make.leading.trailing.equalToSuperview()
                }
            }
        }
        
        nameLabel.text = name
        if let amount = amount {
            if amount >= 0 {
                amountLabel.amountFormatter(amount, symbol: currency)
                amountLabel.textColor = .label
            } else {
                amountLabel.amountFormatter(amount, sign: "-", symbol: currency)
                amountLabel.textColor = .systemRed
            }
        }
        iconImageView.image = UIImage(systemName: icon)
        iconContainerView.backgroundColor = UIColor(hex: color)
    }
    
    func configureForCategory(_ category: CategoryModel, currency: String) {
        configure(
            name: category.name,
            amount: category.amount,
            icon: category.icon,
            color: category.color,
            currency: currency
        )
    }
    
    func configureForWallet(_ wallet: WalletModel, currency: String) {
        configure(
            name: wallet.name,
            amount: wallet.amount,
            icon: wallet.icon,
            color: wallet.color,
            currency: currency
        )
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(iconContainerView)
        containerView.addSubview(amountLabel)
        iconContainerView.addSubview(iconImageView)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        iconContainerView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }

        iconImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }

        nameLabel.snp.makeConstraints { make in
            make.bottom.equalTo(iconContainerView.snp.top).offset(-4)
            make.leading.trailing.equalToSuperview()
        }

        amountLabel.snp.makeConstraints { make in
            make.top.equalTo(iconContainerView.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        amountLabel.text = nil
        iconImageView.image = nil
        iconContainerView.backgroundColor = nil
    }
} 
