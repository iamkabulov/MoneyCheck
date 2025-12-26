import UIKit
import SnapKit

final class SectionBackgroundDecorationView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        self.backgroundColor = .systemGray6
        self.clipsToBounds = true
        self.layer.cornerRadius = 16
    }
}
