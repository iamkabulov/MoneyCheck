import UIKit
import SnapKit

final class SectionHeaderView: UICollectionReusableView {
    static let reuseIdentifier = String(describing: SectionHeaderView.self)
    
    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .label
        return label
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .label
        label.textAlignment = .right
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
    func configure(title: String, amount: Double? = nil) {
        titleLabel.text = title
        if let amount = amount {
            amountLabel.text = formatAmount(amount)
            amountLabel.isHidden = false
        } else {
            amountLabel.isHidden = true
        }
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        addSubview(titleLabel)
        addSubview(amountLabel)

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        amountLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
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
} 
