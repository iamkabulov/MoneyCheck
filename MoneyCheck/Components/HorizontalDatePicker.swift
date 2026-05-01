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

    // MARK: - Private
    private let feedbackGenerator = UISelectionFeedbackGenerator()
    private let calendar = Calendar.current
    private let baseDate = Date()

    private let todayIndex = 5000
    private var selectedIndex: Int = 5000
    private var didScrollInitially = false

    private let cellWidthRatio: CGFloat = 3.5

    // MARK: - UI

    private let calendarButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "calendar"), for: .normal)
        button.tintColor = .systemBlue
        button.backgroundColor = .clear
        button.layer.cornerRadius = 12
        return button
    }()

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
        cv.backgroundColor = .clear
        return cv
    }()

    private let highlightView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 2
        view.layer.cornerRadius = 12
        view.layer.borderColor = UIColor.systemBlue.cgColor
        view.isUserInteractionEnabled = false
        return view
    }()

    // MARK: - Init

    init(initialDate: Date = Date()) {
        let days = Calendar.current.dateComponents(
            [.day],
            from: Calendar.current.startOfDay(for: Date()),
            to: Calendar.current.startOfDay(for: initialDate)
        ).day ?? 0

        self.selectedIndex = todayIndex + days
        super.init(frame: .zero)
        setupUI()
        calendarButton.addTarget(self, action: #selector(calendarTapped), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if !didScrollInitially {
            scrollToIndex(selectedIndex, animated: false)
            didScrollInitially = true
        }
    }

    // MARK: - Setup UI

    private func setupUI() {
        addSubview(calendarButton)
        addSubview(datePicker)
        addSubview(highlightView)

        calendarButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }

        datePicker.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
            make.leading.equalTo(calendarButton.snp.trailing).offset(8)
        }

        highlightView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(1 / (0.6 + cellWidthRatio))
            make.height.equalToSuperview()
        }
    }
}

// MARK: - UICollectionView DataSource / Delegate

extension HorizontalDatePicker: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        10000
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: DateCell.reuseIdentifier,
            for: indexPath
        ) as? DateCell else {
            return UICollectionViewCell()
        }

        let offset = indexPath.item - todayIndex
        if let date = calendar.date(byAdding: .day, value: offset, to: baseDate) {
            cell.configure(
                with: date,
                isSelected: indexPath.item == selectedIndex
            )
        }

        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = collectionView.bounds.width / cellWidthRatio
        return CGSize(width: width, height: collectionView.bounds.height)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.item
        scrollToIndex(indexPath.item, animated: true)
        datePicker.reloadData()

        feedbackGenerator.selectionChanged()
        onDateSelected?(dateForIndex(indexPath.item))
        feedbackGenerator.prepare()
    }
}

// MARK: - Snapping & Scroll

extension HorizontalDatePicker: UIScrollViewDelegate {

    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        let bounds = datePicker.bounds
        let cellWidth = bounds.width / cellWidthRatio
        let proposedX = targetContentOffset.pointee.x

        let selectionAreaX = proposedX + bounds.width - cellWidth / 2
        let rawIndex = selectionAreaX / cellWidth - 0.5
        let snappedIndex = max(0, Int(round(rawIndex)))

        let snappedCenterX = (CGFloat(snappedIndex) + 0.5) * cellWidth
        let maxOffsetX = max(0, datePicker.contentSize.width - bounds.width)

        var newOffsetX = snappedCenterX - (bounds.width - cellWidth / 2)
        newOffsetX = min(max(newOffsetX, 0), maxOffsetX)

        targetContentOffset.pointee.x = newOffsetX
    }

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
        let cellWidth = bounds.width / cellWidthRatio
        let selectionAreaX = datePicker.contentOffset.x + bounds.width - cellWidth / 2

        let rawIndex = selectionAreaX / cellWidth - 0.5
        let index = max(0, Int(round(rawIndex)))

        selectedIndex = index
        datePicker.reloadData()

        feedbackGenerator.selectionChanged()
        onDateSelected?(dateForIndex(index))
        feedbackGenerator.prepare()
    }

    private func scrollToIndex(_ index: Int, animated: Bool) {
        let bounds = datePicker.bounds
        let cellWidth = bounds.width / cellWidthRatio
        let centerX = (CGFloat(index) + 0.5) * cellWidth
        let offsetX = centerX - (bounds.width - cellWidth / 2)

        datePicker.setContentOffset(
            CGPoint(x: max(0, offsetX), y: 0),
            animated: animated
        )
    }
}

// MARK: - Calendar Button

private extension HorizontalDatePicker {

    @objc func calendarTapped() {
        let vc = CalendarPanModalViewController()
        vc.modalPresentationStyle = .custom

        vc.onDateSelected = { [weak self] date in
            self?.selectDate(date)
        }

        parentViewController?.present(vc, animated: true)
    }

    func selectDate(_ date: Date) {
        let days = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: baseDate),
            to: calendar.startOfDay(for: date)
        ).day ?? 0

        let index = todayIndex + days
        selectedIndex = index

        scrollToIndex(index, animated: true)
        datePicker.reloadData()

        feedbackGenerator.selectionChanged()
        onDateSelected?(date)
        feedbackGenerator.prepare()
    }

    func dateForIndex(_ index: Int) -> Date {
        let offset = index - todayIndex
        return calendar.date(byAdding: .day, value: offset, to: baseDate) ?? Date()
    }
}

// MARK: - UIView → UIViewController

private extension UIView {
    var parentViewController: UIViewController? {
        var responder: UIResponder? = self
        while let next = responder?.next {
            if let vc = next as? UIViewController {
                return vc
            }
            responder = next
        }
        return nil
    }
}
