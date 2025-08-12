import UIKit

extension UITextField {
    func addDoneButtonOnKeyboard(title: String = "Готово") {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: title, style: .done, target: self, action: #selector(_doneButtonTapped))
        toolbar.items = [flexible, done]
        inputAccessoryView = toolbar
    }

    @objc private func _doneButtonTapped() {
        resignFirstResponder()
    }
} 