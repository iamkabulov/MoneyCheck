import UIKit

class InfiniteDatePickerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    private let pickerView = UIPickerView()
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ru_RU")
        df.dateFormat = "dd MMMM" // например "28 августа"
        return df
    }()
    
    // большое количество строк для имитации бесконечности
    private let rowCount = 10000
    private var baseDate = Date() // сегодня
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        pickerView.dataSource = self
        pickerView.delegate = self
        view.addSubview(pickerView)
        
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pickerView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // выбрать "сегодня" по центру
        pickerView.selectRow(rowCount / 2, inComponent: 0, animated: false)
    }
    
    // MARK: - UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        rowCount
    }
    
    // MARK: - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let offset = row - rowCount / 2
        if let date = calendar.date(byAdding: .day, value: offset, to: baseDate) {
            return dateFormatter.string(from: date)
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let offset = row - rowCount / 2
        if let date = calendar.date(byAdding: .day, value: offset, to: baseDate) {
            print("Выбрана дата: \(date)")
        }
    }
}
