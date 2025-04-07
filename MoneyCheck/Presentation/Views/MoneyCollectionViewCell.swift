import UIKit
import SnapKit

final class MoneyCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: MoneyCollectionViewCell.self)
    
    // MARK: - UI Components
    private let containerView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 0
        view.distribution = .equalCentering
        view.alignment = .center
        return view
    }()

    let iconContainerView: UIView = {
        let view = UIView()
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
        label.font = .preferredFont(forTextStyle: .footnote)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .footnote)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 1
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
    func configure(name: String, amount: Double, icon: String, color: String) {
        nameLabel.text = name
        amountLabel.text = formatAmount(amount)
        iconImageView.image = UIImage(systemName: icon)
        iconContainerView.backgroundColor = UIColor(hex: color)
    }
    
    func configureForCategory(_ category: CategoryModel) {
        configure(
            name: category.name,
            amount: category.amount,
            icon: category.icon,
            color: category.color
        )
    }
    
    func configureForWallet(_ wallet: WalletModel) {
        configure(
            name: wallet.name,
            amount: wallet.balance,
            icon: wallet.type.icon,
            color: wallet.type.color
        )
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        contentView.addSubview(containerView)
        iconContainerView.addSubview(iconImageView)
        containerView.addArrangedSubview(nameLabel)
        containerView.addArrangedSubview(iconContainerView)
        containerView.addArrangedSubview(amountLabel)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        iconContainerView.snp.makeConstraints { make in
            make.height.width.equalTo(48)
        }

        iconImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
        }
    }
    
    private func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        
        if let formattedAmount = formatter.string(from: NSNumber(value: amount)) {
            return "\(formattedAmount) ₸"
        }
        return "0 ₸"
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        amountLabel.text = nil
        iconImageView.image = nil
        containerView.backgroundColor = nil
    }
} 
