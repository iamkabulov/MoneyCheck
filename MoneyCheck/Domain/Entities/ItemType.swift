//
//  ItemType.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 25.04.2025.
//

enum ItemType:String, Codable, CaseIterable {
    case income
    case wallet
    case category

    var title: String {
        switch self {
        case .income: return "Доход"
        case .wallet: return "Кошелек"
        case .category: return "Категория"
        }
    }

    var icons: [String] {
        switch self {
        case .income:
            return [
                "creditcard", "wallet.pass", "banknote", "dollarsign.circle",
                "cart", "bag", "basket", "gift", "house", "cloud"
            ]
        case .wallet:
            return [
                "creditcard", "wallet.pass", "banknote", "dollarsign.circle",
                "building.columns", "building", "lock", "house", "cloud"
            ]
        case .category:
            return [
                "cart", "bag", "basket", "gift",
                "house", "car", "bus", "airplane",
                "fork.knife", "cup.and.saucer", "wineglass",
                "cross.case", "star", "person", "gamecontroller", "house", "cloud"
            ]
        }
    }

    var colors: [String] {
        switch self {
        case .income:
            return [
                "#4CAF50", "#2196F3", "#F44336", "#FFC107", "#9C27B0",
                "#FF9800", "#00BCD4", "#795548", "#607D8B", "#E91E63",
                "#3F51B5", "#8BC34A", "#CDDC39", "#009688", "#673AB7",
                "#FF5722", "#9E9E9E", "#4DD0E1", "#AED581", "#BA68C8"
            ]
        case .wallet:
            return [
                "#E91E63", "#2196F3", "#F44336", "#FFC107", "#9C27B0",
                "#FF9800", "#00BCD4", "#795548", "#607D8B", "#4CAF50",
                "#3F51B5", "#8BC34A", "#CDDC39", "#009688", "#673AB7",
                "#FF5722", "#9E9E9E", "#4DD0E1", "#AED581", "#BA68C8"
            ]
        case .category:
            return [
                "#607D8B", "#E91E63", "#2196F3", "#F44336", "#FFC107",
                "#9C27B0", "#FF9800", "#00BCD4", "#795548", "#4CAF50",
                "#3F51B5", "#8BC34A", "#CDDC39", "#009688", "#673AB7",
                "#FF5722", "#9E9E9E", "#4DD0E1", "#AED581", "#BA68C8"
            ]
        }
    }
}
