import UIKit
import SnapKit
import Foundation

enum TransferType {
    case income(sourceIncome: IncomeModel, targetWallet: WalletModel)
    case wallet(sourceWallet: WalletModel, targetWallet: WalletModel)
    case category(sourceWallet: WalletModel, targetCategory: CategoryModel)
    
    var title: String {
        switch self {
        case .income(let income, let wallet):
            return "Перевести из \(income.name) в \(wallet.name)"
        case .wallet(let source, let target):
            return "Перевести из \(source.name) в \(target.name)"
        case .category(let wallet, let category):
            return "Перевести из \(wallet.name) в \(category.name)"
        }
    }
}

protocol TransferBottomSheetDelegate: AnyObject {
    func transferBottomSheet(transferType: TransferType, didConfirmAmount amount: Double, date: Date, comment: String?)
    func transferBottomSheetDidCancel()
}

final class TransferBottomSheetViewController: UIViewController {
    // MARK: - Properties
    weak var delegate: TransferBottomSheetDelegate?
    let transferType: TransferType
    private let feedbackGenerator = UISelectionFeedbackGenerator()
    private let calendar = Calendar.current
    private let baseDate = Date()
    private let todayIndex = 5000
    private var selectedIndex: Int = 5000
    private lazy var datePicker: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(DateCell.self, forCellWithReuseIdentifier: "DateCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = .fast
        return collectionView
    }()

    private lazy var highlightView: UIView = {
        let highlightView = UIView()
        highlightView.layer.borderWidth = 2
        highlightView.layer.borderColor = UIColor.systemBlue.cgColor
        highlightView.layer.cornerRadius = 5
        highlightView.isUserInteractionEnabled = false

        return highlightView
    }()

    private var date = Date()

    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .label
        return label
    }()
    
    private lazy var amountInput: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Сумма"
        textField.keyboardType = .decimalPad
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .secondarySystemGroupedBackground
        textField.textColor = .label
        return textField
    }()

    private lazy var commentInput: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Комментарий"
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .secondarySystemGroupedBackground
        textField.textColor = .label
        return textField
    }()

    private let buttonsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        return stack
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отмена", for: .normal)
        button.setTitleColor(UIColor(hex: "#FF3B30"), for: .normal)
        button.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.transferBottomSheetDidCancel()
        }, for: .touchDown)
        return button
    }()
    
    private lazy var okButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("OK", for: .normal)
        button.setTitleColor(UIColor(hex: "#007AFF"), for: .normal)
        button.addAction(UIAction { [weak self] _ in
            guard let self = self,
                  let amountText = self.amountInput.text,
                  let amount = Double(amountText.replacingOccurrences(of: ",", with: ".")),
                  amount > 0 else {
                return
            }
            self.delegate?.transferBottomSheet(transferType: transferType,didConfirmAmount: amount, date: date, comment: commentInput.text)
        }, for: .touchDown)
        return button
    }()

    // MARK: - Initialization
    init(transferType: TransferType) {
        self.transferType = transferType
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        isModalInPresentation = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("TransferBottomSheet deinit")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardDismissGesture()
        feedbackGenerator.prepare()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        amountInput.becomeFirstResponder()
        DispatchQueue.main.async {
            self.scrollToIndex(self.todayIndex, animated: false)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        if let sheet = sheetPresentationController {
            sheet.detents = [.custom { _ in 300 }]
        }

        titleLabel.text = transferType.title

        
        view.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(amountInput)
        containerView.addSubview(commentInput)
        containerView.addSubview(datePicker)
        containerView.addSubview(highlightView)
        containerView.addSubview(buttonsStack)

        buttonsStack.addArrangedSubview(cancelButton)
        buttonsStack.addArrangedSubview(okButton)
        
        containerView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        amountInput.addDoneButtonOnKeyboard()
        amountInput.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        commentInput.snp.makeConstraints { make in
            make.top.equalTo(amountInput.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        datePicker.snp.makeConstraints { make in
            make.top.equalTo(commentInput.snp.bottom).offset(16)
            make.leading.equalTo(containerView.snp.leading)
            make.trailing.equalTo(containerView.snp.trailing).inset(16)
            make.height.equalTo(50)
        }

        highlightView.snp.makeConstraints { make in
            make.top.equalTo(commentInput.snp.bottom).offset(16)
            make.trailing.equalTo(containerView.snp.trailing).inset(16)
            make.width.equalTo(datePicker.snp.width).multipliedBy(1.0 / 3.5)
            make.height.equalTo(datePicker.snp.height)
        }

        buttonsStack.snp.makeConstraints { make in
            make.top.equalTo(datePicker.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }
}

// MARK: - DataSource
extension TransferBottomSheetViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        10000
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCell", for: indexPath) as? DateCell else {
            return UICollectionViewCell() }
        let offset = indexPath.item - todayIndex
        if let date = calendar.date(byAdding: .day, value: offset, to: baseDate) {
            let isSelected = indexPath.item == selectedIndex
            cell.configure(with: date, isSelected: isSelected)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = collectionView.bounds.width / 3.5
        return CGSize(width: w, height: collectionView.bounds.height)
    }
}

// MARK: - Snapping под выбор справа
extension TransferBottomSheetViewController: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {

        let bounds = datePicker.bounds
        let cellWidth = bounds.width / 3.5
        let proposedX = targetContentOffset.pointee.x

        // координата "selection зоны" справа
        let selectionAreaX = proposedX + bounds.width - cellWidth / 2

        // индекс ближайшей ячейки к этой зоне
        let rawIndex = selectionAreaX / cellWidth - 0.5
        let snappedIndex = max(0, Int(round(rawIndex)))

        // новый оффсет так, чтобы выбранная ячейка совпала с рамкой справа
        let snappedCellCenterX = (CGFloat(snappedIndex) + 0.5) * cellWidth
        var newOffsetX = snappedCellCenterX - (bounds.width - cellWidth / 2)

        // clamp
        let maxOffsetX = max(0, datePicker.contentSize.width - bounds.width)
        newOffsetX = min(max(newOffsetX, 0), maxOffsetX)

        targetContentOffset.pointee.x = newOffsetX
    }

    private func scrollToIndex(_ index: Int, animated: Bool) {
        let bounds = datePicker.bounds
        let cellWidth = bounds.width / 3.5
        let snappedCellCenterX = (CGFloat(index) + 0.5) * cellWidth
        let offsetX = snappedCellCenterX - (bounds.width - cellWidth / 2)
        datePicker.setContentOffset(CGPoint(x: offsetX, y: 0), animated: animated)
    }

    // MARK: - Scroll Delegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateSelectedDate()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            updateSelectedDate()
        }
    }

    private func updateSelectedDate() {
        let bounds = datePicker.bounds
        let cellWidth = bounds.width / 3.5
        // зона выбора справа
        let selectionAreaX = datePicker.contentOffset.x + bounds.width - cellWidth / 2

        let rawIndex = selectionAreaX / cellWidth - 0.5
        let newIndex = max(0, Int(round(rawIndex)))

        selectedIndex = newIndex
        datePicker.reloadData()
        feedbackGenerator.selectionChanged()
        date = dateForIndex(selectedIndex)
    }

    private func dateForIndex(_ index: Int) -> Date {
        let offset = index - todayIndex
        guard let today = calendar.date(byAdding: .day, value: offset, to: baseDate) else { return Date() }
        return today
    }
}
