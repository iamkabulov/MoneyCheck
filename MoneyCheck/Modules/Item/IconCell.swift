import UIKit
import SnapKit

final class IconCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: IconCell.self)
    
    private let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.layer.cornerRadius = self.bounds.width / 2
        contentView.addSubview(iconView)
        
        iconView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
    }
    
    func configure(with icon: String, color: String, selectedIcon: String) {
        iconView.image = UIImage(systemName: icon)
        contentView.backgroundColor = UIColor(hex: color)
        if selectedIcon == icon {
            transform = CGAffineTransform(scaleX: 1, y: 1)
        } else {
            transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        }
    }
} 
