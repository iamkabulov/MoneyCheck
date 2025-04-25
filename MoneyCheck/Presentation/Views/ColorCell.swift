import UIKit

final class ColorCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: ColorCell.self)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        layer.cornerRadius = self.bounds.width / 2
    }
    
    func configure(with color: String, selectedColor: String) {
        backgroundColor = UIColor(hex: color)
        if selectedColor == color {
            transform = CGAffineTransform(scaleX: 1, y: 1)
        } else {
            transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        }
    }
} 
