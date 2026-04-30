//
//  FitnessSegmentedControl.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 28.12.2025.
//
import UIKit


import SwiftUI

struct SegmentedPicker: View {

    let items: [TransactionType]
    @Binding var selectedItem: TransactionType

    var body: some View {
        GeometryReader { geo in
            let segmentWidth = geo.size.width / CGFloat(items.count)

            ZStack(alignment: .leading) {

                // Background
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.systemGray6))

                // Sliding selection
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray3))
                    .frame(
                        width: segmentWidth - 8,
                        height: geo.size.height - 8
                    )
                    .offset(x: CGFloat(items.firstIndex(of: selectedItem) ?? 0) * segmentWidth + 4)
                    .animation(
                        .spring(response: 0.3, dampingFraction: 0.85),
                        value: selectedItem.title
                    )

                // Labels
                HStack(spacing: 0) {
                    ForEach(items.indices, id: \.self) { index in
                        Text(items[index].title)
                            .font(
                                items[index] == selectedItem
                                ? .system(size: 15, weight: .medium)
                                : .system(size: 15, weight: .regular)
                            )
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedItem = items[index]
                                UISelectionFeedbackGenerator().selectionChanged()
                            }
                            .accessibilityIdentifier("testik\(index)")
                    }
                }
            }
        }
        .frame(height: 30)
    }
}
