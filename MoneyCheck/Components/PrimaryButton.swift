//
//  PrimaryButton.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 25.08.2025.
//

import UIKit

final class PrimaryButton: UIButton {

    private var gradientLayer: CAGradientLayer?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        addActions()
        setGradientBackground(colors: [UIColor(hex: "#000000"), UIColor(hex: "#3d3d3d")])
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer?.frame = bounds
    }

    // MARK: - Private
    private func configureUI() {
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor(hex: "#494949").cgColor
        setTitleColor(.systemBackground, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        heightAnchor.constraint(equalToConstant: 40).isActive = true
        clipsToBounds = true
    }

    private func addActions() {
        addTarget(self, action: #selector(animateDown), for: [.touchDown, .touchDragEnter])
        addTarget(self, action: #selector(animateUp), for: [.touchUpInside, .touchCancel, .touchDragExit])
    }

    @objc private func animateDown() {
        UIView.animate(withDuration: 0.15,
                       delay: 0,
                       options: [.curveEaseInOut, .allowUserInteraction],
                       animations: {
            self.transform = CGAffineTransform(scaleX: 0.94, y: 0.94)
        })
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    @objc private func animateUp() {
        UIView.animate(withDuration: 0.25,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.5,
                       options: [.curveEaseInOut, .allowUserInteraction],
                       animations: {
            self.transform = .identity
        })
    }

    // MARK: - Public
    func setEnabled(_ isEnabled: Bool) {
        if isEnabled {
            setGradientBackground(colors: [UIColor(hex: "#000000"), UIColor(hex: "#3d3d3d")])
        } else {
            setGradientBackground(colors: [UIColor(hex: "#6c6e6c"), UIColor(hex: "#8f918f")])
        }
        self.isEnabled = isEnabled
    }

    func setGradientBackground(colors: [UIColor], startPoint: CGPoint = CGPoint(x: 0.5, y: 0), endPoint: CGPoint = CGPoint(x: 0.5, y: 1)) {
        gradientLayer?.removeFromSuperlayer() // если был старый

        let gradient = CAGradientLayer()
        gradient.colors = colors.map { $0.cgColor }
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        gradient.frame = bounds
        gradient.cornerRadius = layer.cornerRadius

        layer.insertSublayer(gradient, at: 0)
        gradientLayer = gradient
    }
}

