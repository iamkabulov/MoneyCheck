//
//  DonutChartView.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 22.12.2025.
//


import SwiftUI
import Charts

struct DonutChartView: View {

    @ObservedObject var viewModel: TransactionsAnalyticsViewModel
    private let minPercentageToShowLabel: Double = 0.05 // 5%
    let onLegendTap: (DonutChartItem) -> Void

    private var total: Double {
        let filtered = viewModel.chartDonutItems.filter { item in
            if viewModel.selectedCategoryIds.contains(item.id) {
                return true
            }
            return false
        }
        return filtered.reduce(0) { $0 + $1.value }
    }

    var body: some View {
        VStack {
            SegmentedPicker(
                items: [.expense, .income],
                selectedItem: $viewModel.type
            )
            .padding(.top, 4)
            .padding(.horizontal, 8)
            ZStack {
                let displayedItems = viewModel.chartDonutItems.filter {
                    viewModel.selectedCategoryIds.contains($0.id)
                }
                Chart(displayedItems) { item in
                    let percentage = item.value / total

                    SectorMark(
                        angle: .value("Value", item.value),
                        innerRadius: .ratio(0.6),
                        angularInset: 0
                    )
                    .foregroundStyle(item.color)
                    .annotation(
                        position: .overlay,
                        alignment: .trailingLastTextBaseline
                    ) {
                        if percentage >= minPercentageToShowLabel {
                            Text("\(Int(percentage * 100))%")
                                .font(.caption2.bold())
                                .foregroundColor(.white)
                        }
                    }
                }
                //TODO: - подумать над анимацией только чарта
//                .animation(
//                    .interpolatingSpring(duration: 0.7),
//                    value: displayedItems
//                )
                .chartLegend(.hidden)
                

                // Центр с суммой
                VStack(spacing: 4) {
                    Text("\(Int(total)) ₸")
                        .font(.body)
                        .foregroundStyle(.primary)
                }
            }
            .frame(height: 180)
        }
        // Легенда
        LazyVGrid(
            columns: [
                GridItem(.adaptive(minimum: 110), spacing: 8)
            ],
            alignment: .center,
            spacing: 8
        ) {
            ForEach(viewModel.chartDonutItems.filter { $0.value > 0 }) { item in
                Button {
                    withAnimation(.easeInOut) {
                        viewModel.toggleSelection(for: item)
                    }
                    onLegendTap(item)
                } label: {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(item.color)
                            .frame(width: 8, height: 8)

                        Text("\(item.title)")
                            .font(.caption)
                    }
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                viewModel.isSelected(item)
                                ? item.color.opacity(0.15)
                                : Color.clear
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                viewModel.isSelected(item)
                                ? item.color
                                : item.color.opacity(0.3),
                                lineWidth: 1
                            )
                    )
                    .opacity(viewModel.isSelected(item) ? 1 : 0.35)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 8)
    }
}
