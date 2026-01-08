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
    
    private let amountLabel: AmountLabel = {
        let label = AmountLabel()
//        label.font = .preferredFont(forTextStyle: .body)
//        label.textColor = .label
//        label.textAlignment = .right
        return label
    }()

    private let arrowImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "chevron.down", withConfiguration: UIImage.SymbolConfiguration(pointSize: 10, weight: .medium))
        iv.tintColor = .label
        return iv
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
    func configure(title: String, amount: Double, collapsed: Bool, symbol: String) {
        titleLabel.text = title
        if amount >= 0 {
            amountLabel.amountFormatter(amount, symbol: symbol)
            amountLabel.textColor = .label
        } else {
            amountLabel.amountFormatter(amount, sign: "-", symbol: symbol)
            amountLabel.textColor = .systemRed
        }

        // Поворот стрелочки при изменении состояния
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.fromValue = collapsed ? 0 : -Double.pi/2
        rotation.toValue = collapsed ? -Double.pi/2 : 0
        rotation.duration = 0.35
        rotation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        rotation.fillMode = .forwards
        rotation.isRemovedOnCompletion = false

        arrowImageView.layer.add(rotation, forKey: "rotation")
    }

    // MARK: - Private Methods
    private func setupUI() {
        addSubview(titleLabel)
        addSubview(amountLabel)
        addSubview(arrowImageView)

        arrowImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(arrowImageView.snp.centerY)
            make.leading.equalTo(arrowImageView.snp.trailing).offset(4)
        }

        amountLabel.snp.makeConstraints { make in
            make.leading.equalTo(snp.centerX)
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
//    private func formatAmount(_ amount: Double) -> String {
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .decimal
//        formatter.groupingSeparator = " "
//        formatter.minimumFractionDigits = 0
//        formatter.maximumFractionDigits = 2
//        
//        if let formattedAmount = formatter.string(from: NSNumber(value: amount)) {
//            return "\(formattedAmount) ₸"
//        }
//        return "0 ₸"
//    }
} 
