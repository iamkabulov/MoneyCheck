import UIKit

final class SectionBackgroundDecorationView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 16
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
} 