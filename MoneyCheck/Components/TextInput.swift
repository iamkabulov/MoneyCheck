//
//  TextInput.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 11.09.2025.
//

import UIKit
import SnapKit

final class TextInput: UITextField {

    private let textInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.borderWidth = 1
        layer.cornerRadius = 8
        layer.borderColor = UIColor.systemGray5.cgColor
        textColor = .label
        delegate = self
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // обычный текст
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textInset)
    }

    // текст при редактировании (курсор)
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textInset)
    }

    // placeholder
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textInset)
    }

    func validate(_ rule: (String) -> Bool) -> Bool {
        let isValid = rule(text ?? "")

        UIView.animate(withDuration: 0.5) {
            self.layer.borderColor = isValid ? UIColor.systemGray5.cgColor : UIColor.systemRed.cgColor
        }

        return isValid
    }
}

extension TextInput: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        textField.layer.borderColor = UIColor(hex: "#63E668").cgColor
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor(hex: "#63E668").cgColor
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.systemGray5.cgColor
    }
}
