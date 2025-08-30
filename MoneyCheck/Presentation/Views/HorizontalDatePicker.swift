//
//  HorizontalDatePicker.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 30.08.2025.
//

import UIKit
import SnapKit

final class HorizontalDatePicker: UIView {

    // MARK: - Public API
    var onDateSelected: ((Date) -> Void)?

    private let cellWidth: CGFloat

    private let feedbackGenerator = UISelectionFeedbackGenerator()
    private let calendar = Calendar.current
    private let baseDate = Date()
    private let todayIndex = 5000
    private var selectedIndex: Int = 5000


    // MARK: - UI
    private lazy var datePicker: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.showsHorizontalScrollIndicator = false
        cv.decelerationRate = .fast
        cv.dataSource = self
        cv.delegate = self
        cv.register(DateCell.self, forCellWithReuseIdentifier: DateCell.reuseIdentifier)
        return cv
    }()

    private let highlightView = UIView()

    private var didScrollInitially = false

    // MARK: - Init
    init(
        initialDate: Date = Date(),
        cellWidth: CGFloat = UIScreen.main.bounds.width / 3.5
    ) {
        let days = Calendar.current.dateComponents([.day],
            from: calendar.startOfDay(for: Date()),
            to: calendar.startOfDay(for: initialDate)
        ).day ?? 0
        self.selectedIndex = todayIndex + days
        self.cellWidth = cellWidth
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if !didScrollInitially {
            self.scrollToIndex(selectedIndex, animated: false)
            didScrollInitially = true
        }
    }

    // MARK: - Setup
    private func setupUI() {
        addSubview(datePicker)
        datePicker.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        highlightView.layer.borderWidth = 2
        highlightView.layer.cornerRadius = 12
        highlightView.layer.borderColor = UIColor.systemBlue.cgColor
        highlightView.isUserInteractionEnabled = false
        addSubview(highlightView)
        highlightView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(1/3.5)
            make.height.equalToSuperview()
        }
    }
}

// MARK: - DataSource
extension HorizontalDatePicker: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        10000
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DateCell.reuseIdentifier, for: indexPath) as? DateCell else {
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
extension HorizontalDatePicker: UIScrollViewDelegate {
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

    func scrollToIndex(_ index: Int, animated: Bool) {
        let bounds = datePicker.bounds
        let cellWidth = bounds.width / 3.5
        let snappedCellCenterX = (CGFloat(index) + 0.5) * cellWidth
        let offsetX = snappedCellCenterX - (bounds.width - cellWidth / 2)
        datePicker.setContentOffset(CGPoint(x: offsetX, y: 0), animated: false)
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
        onDateSelected?(dateForIndex(selectedIndex))

        feedbackGenerator.prepare()
    }

    private func dateForIndex(_ index: Int) -> Date {
        let offset = index - todayIndex
        guard let today = calendar.date(byAdding: .day, value: offset, to: baseDate) else { return Date() }
        return today
    }
}
