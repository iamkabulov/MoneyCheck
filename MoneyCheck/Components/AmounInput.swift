//
//  NumberTextField.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 08.09.2025.
//


import UIKit

final class AmounInput: UITextField, UITextFieldDelegate {

    // Настройка форматтера (локаль, разделители, дробные цифры)
    let formatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.groupingSeparator = " " // можно взять из Locale, но явно задаём (formatter иметь можно и с локалью)
        f.decimalSeparator = Locale.current.decimalSeparator ?? ","
        f.maximumFractionDigits = 2 // визуально форматтер не будет трогать дробную часть в нашей реализации
        return f
    }()

    var maxFractionDigits: Int { formatter.maximumFractionDigits }
    private var decimalSeparator: String { formatter.decimalSeparator ?? "," }
    private var groupingSeparator: String { formatter.groupingSeparator ?? " " }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    private func commonInit() {
        borderStyle = .roundedRect
        backgroundColor = .secondarySystemGroupedBackground
        textColor = .label
        keyboardType = .decimalPad
        delegate = self
    }

    // Убираем группирующие пробелы и non-breaking space
    private func clean(_ str: String) -> String {
        str.replacingOccurrences(of: groupingSeparator, with: "")
           .replacingOccurrences(of: "\u{00A0}", with: "")
    }

    // Переводим NSRange (в отформатированной строке) -> диапазон для "сырой" строки (без группировок)
    private func rawRange(fromFormattedRange range: NSRange, formatted: String) -> NSRange {
        let ns = formatted as NSString
        let locBefore = ns.substring(to: range.location)
        let locBeforeCleanCount = clean(locBefore).count
        let locEnd = ns.substring(to: range.location + range.length)
        let locEndCleanCount = clean(locEnd).count
        return NSRange(location: locBeforeCleanCount, length: max(0, locEndCleanCount - locBeforeCleanCount))
    }

    // Форматируем только целую часть, дробную часть добавляем "как есть"
    private func formattedText(fromRaw raw: String) -> String {
        if raw.isEmpty { return "" }
        let parts = raw.components(separatedBy: decimalSeparator)
        let intPart = parts.first ?? ""
        let fracPart = parts.count > 1 ? parts[1] : nil

        // форматируем целую часть через временный форматтер (без дробей)
        if intPart.isEmpty && fracPart == nil { return "" }

        var formattedInt: String
        if intPart.isEmpty {
            formattedInt = "0"
        } else {
            let intNumber = NSDecimalNumber(string: intPart)
            let intFormatter = NumberFormatter()
            intFormatter.numberStyle = .decimal
            intFormatter.groupingSeparator = groupingSeparator
            intFormatter.decimalSeparator = decimalSeparator
            intFormatter.maximumFractionDigits = 0
            formattedInt = intFormatter.string(from: intNumber) ?? intPart
        }

        if let frac = fracPart {
            return formattedInt + decimalSeparator + frac
        } else {
            return formattedInt
        }
    }

    // Найти позицию в отформатированной строке, соответствующую rawPosition (кол-ву символов без группировок слева)
    private func formattedIndex(forRawPosition rawPos: Int, inFormatted formatted: String) -> Int {
        if rawPos <= 0 { return 0 }
        var rawCount = 0
        for (i, ch) in formatted.enumerated() {
            let s = String(ch)
            if s != groupingSeparator { rawCount += 1 }
            if rawCount == rawPos {
                // позиция — после i-ого символа => offset = i+1
                return i + 1
            }
        }
        return formatted.count
    }

    // MARK: - Delegate
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        let currentText = textField.text ?? ""
        // нормализуем ввод: если ввели "." или "," -> превращаем в локальный separator
        var replacement = string
        if string == "." || string == "," { replacement = decimalSeparator }

        // фильтруем: разрешаем только цифры и локальный разделитель (на случай вставки)
        let allowed = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: decimalSeparator))
        let filteredReplacement = replacement.components(separatedBy: allowed.inverted).joined()

        // mapping диапазона на "сырой"
        let rawCurrent = clean(currentText)
        let rawRange = rawRange(fromFormattedRange: range, formatted: currentText)
        let rawNSString = rawCurrent as NSString
        let rawUpdated = rawNSString.replacingCharacters(in: rawRange, with: filteredReplacement)

        // если попытка ввести второй разделитель — блокируем
        if rawUpdated.components(separatedBy: decimalSeparator).count - 1 > 1 {
            return false
        }

        // ограничение дробной части
        if let sepIndex = rawUpdated.firstIndex(of: Character(decimalSeparator)) {
            let fractionalPart = rawUpdated[rawUpdated.index(after: sepIndex)...]
            if fractionalPart.count > maxFractionDigits {
                return false
            }
        }

        // формируем итоговый текст: отформатированная целая часть + дробная часть (без форматирования)
        let newFormatted = formattedText(fromRaw: rawUpdated)
        textField.text = newFormatted

        // вычисляем позицию каретки в raw (кол-во символов слева в raw)
        let rawCursorPos = rawRange.location + (filteredReplacement as NSString).length

        // переводим rawCursorPos -> позиция в отформатированной строке
        let caretPos = formattedIndex(forRawPosition: rawCursorPos, inFormatted: newFormatted)
        var finalCaretPos = caretPos

        // Хак: если первый символ — разделитель, курсор переносим в конец
        if rawUpdated == decimalSeparator || rawUpdated.hasPrefix("0" + decimalSeparator) {
            finalCaretPos = newFormatted.count
        }

        if let start = textField.position(from: textField.beginningOfDocument, offset: finalCaretPos) {
            textField.selectedTextRange = textField.textRange(from: start, to: start)
        }

        // мы сами обновили текст и каретку
        return false
    }
}
