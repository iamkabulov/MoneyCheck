import UIKit
import SnapKit

final class TransactionCell: UITableViewCell {
    static let reuseIdentifier = String(describing: TransactionCell.self)

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let iconContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = 20
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let commentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    private var currentWalletId: UUID?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        contentView.addSubview(containerView)
        containerView.addSubview(iconContainerView)
        iconContainerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(commentLabel)
        containerView.addSubview(amountLabel)
        
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(4)
        }
        
        iconContainerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
            make.size.equalTo(40)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconContainerView.snp.trailing).offset(12)
            make.top.equalToSuperview().offset(12)
        }
        
        commentLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(iconImageView.snp.centerY).offset(2)
        }
        
        amountLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
        }
    }
    
    func configure(with transaction: TransactionModel, currentWalletId: UUID) {
        self.currentWalletId = currentWalletId
        
        switch transaction.type {
        case .transfer:
            if transaction.destinationId == currentWalletId {
                // Входящий перевод (мы получатели)
                iconImageView.image = UIImage(systemName: transaction.sourceIcon)
                iconContainerView.backgroundColor = UIColor(hex: transaction.sourceColor)
                titleLabel.text = transaction.sourceName
                amountLabel.textColor = .systemGreen
                amountLabel.text = "+\(Double.amountFormatter(transaction.amount)) ₸"
            } else {
                // Исходящий перевод (мы отправители)
                iconImageView.image = UIImage(systemName: transaction.destinationIcon)
                iconContainerView.backgroundColor = UIColor(hex: transaction.destinationColor)
                titleLabel.text = transaction.destinationName
                amountLabel.textColor = .systemBlue
                amountLabel.text = "-\(Double.amountFormatter(transaction.amount)) ₸"
            }
            
        case .expense:
            iconImageView.image = UIImage(systemName: transaction.destinationIcon)
            iconContainerView.backgroundColor = UIColor(hex: transaction.destinationColor)
            titleLabel.text = transaction.destinationName
            amountLabel.textColor = .systemRed
                amountLabel.text = "-\(Double.amountFormatter(transaction.amount)) ₸"

        case .income:
            iconImageView.image = UIImage(systemName: transaction.sourceIcon)
            iconContainerView.backgroundColor = UIColor(hex: transaction.sourceColor)
            titleLabel.text = transaction.sourceName
            amountLabel.textColor = .systemGreen
                amountLabel.text = "+\(Double.amountFormatter(transaction.amount)) ₸"
        }

        if let comment = transaction.comment, comment.isEmpty == false {
            commentLabel.isHidden = false
            commentLabel.text = comment
            titleLabel.snp.remakeConstraints { make in
                make.bottom.equalTo(iconImageView.snp.centerY).inset(2)
                make.leading.equalTo(iconContainerView.snp.trailing).offset(12)
            }
        } else {
            commentLabel.isHidden = true

            titleLabel.snp.remakeConstraints { make in
                make.centerY.equalToSuperview()
                make.leading.equalTo(iconContainerView.snp.trailing).offset(12)
            }

        }
    }
} 

extension Double {
    static func amountFormatter(_ amount: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.groupingSeparator = " " // можно взять из Locale, но явно задаём (formatter иметь можно и с локалью)
        f.decimalSeparator = Locale.current.decimalSeparator ?? ","
        f.maximumFractionDigits = 2 // визуально форматтер не будет трогать дробную часть в нашей реализации
        guard let formattedString = f.string(from: NSNumber(value: amount)) else {
            return "0"
        }
        
        return formattedString
    }
}
