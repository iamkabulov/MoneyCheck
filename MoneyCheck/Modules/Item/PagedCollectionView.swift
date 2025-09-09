//
//  PagedCollectionView.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 09.09.2025.
//
import UIKit

final class PagedCollectionView: UIView {
    // MARK: - UI
    private let titleLabel = UILabel()
    let collectionView: UICollectionView
    let pageControl = UIPageControl()
    
    // MARK: - Init
    init(title: String, itemSize: CGSize) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.itemSize = itemSize
        
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(frame: .zero)
        
        setupUI(title: title)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI(title: String) {
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .secondaryLabel
        
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        
        pageControl.currentPageIndicatorTintColor = .lightGray
        pageControl.pageIndicatorTintColor = .systemGray4
        pageControl.isUserInteractionEnabled = false
        
        addSubview(titleLabel)
        addSubview(collectionView)
        addSubview(pageControl)
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(60) // настраивается извне
        }
        
        pageControl.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Helpers
    func updatePages(itemsCount: Int) {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        let itemWidth = layout.itemSize.width + layout.minimumLineSpacing
        guard itemWidth > 0 else { return }
        
        let itemsPerPage = floor(collectionView.bounds.width / itemWidth)
        guard itemsPerPage > 0 else { return }
        
        let pages = ceil(Double(itemsCount) / itemsPerPage)
        pageControl.numberOfPages = Int(pages)
    }
    
    func updateCurrentPage(scrollView: UIScrollView) {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let itemWidth = layout.itemSize.width + layout.minimumLineSpacing
        guard itemWidth > 0 else { return }
        
        let itemsPerPage = floor(collectionView.bounds.width / itemWidth)
        guard itemsPerPage > 0 else { return }
        
        let page = round(scrollView.contentOffset.x / (itemsPerPage * itemWidth))
        pageControl.currentPage = Int(page)
    }
}
