//
//  CircleIconView.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 09.09.2025.
//
import UIKit
import SnapKit


final class CircleIconView: UIView {

    private var circleView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        return view
    }()

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .white // по умолчанию картинка будет белая
        return iv
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .label
        return label
    }()

    init(image: UIImage?, backgroundColor: UIColor, name: String) {
        super.init(frame: .zero)
        setupView(image: image, backgroundColor: backgroundColor, name: name)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView(image: nil, backgroundColor: .systemGray)
    }

    private func setupView(image: UIImage?, backgroundColor: UIColor, name: String? = nil) {
        circleView.backgroundColor = backgroundColor

        imageView.image = image?.withRenderingMode(.alwaysTemplate)
        nameLabel.text = name
        addSubview(circleView)
        addSubview(imageView)
        addSubview(nameLabel)


        circleView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.height.equalToSuperview()
        }

        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }

        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(circleView.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.circleView.layer.cornerRadius = bounds.width / 2
    }
}
