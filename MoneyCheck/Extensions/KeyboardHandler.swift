//
//  KeyboardHandler.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 10.08.2025.
//

import Foundation
import UIKit

extension UITextField {
    func addDoneButtonOnKeyboard() {
        let width = UIScreen.main.bounds.width
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: width, height: 44))
        toolbar.autoresizingMask = [.flexibleWidth]
        toolbar.isTranslucent = true
        toolbar.barStyle = .default
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(resignFirstResponder)
        )
        toolbar.items = [flexible, done]
        self.inputAccessoryView = toolbar
    }
}

public extension UIViewController {
    func setupKeyboardDismissGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
