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
                    "creditcard", "wallet.pass", "banknote", "dollarsign",
                    "cart", "bag", "basket", "gift", "house", "cloud",
                    "chart.line.uptrend.xyaxis", "arrow.down.circle", "arrow.down.square",
                    "briefcase", "banknote.fill",
                    // из createIncome
                    "dollarsign.circle", "chart.line.uptrend.xyaxis"
                ]

            case .wallet:
                return [
                    "creditcard", "wallet.pass", "banknote", "dollarsign",
                    "building.columns", "building", "lock", "house", "cloud",
                    "key", "shield", "checkmark.shield",
                    "eurosign.circle", "yensign.circle", "bitcoinsign.circle",
                ]

            case .category:
                return [
                    "cart", "bag", "basket", "gift",
                    "house", "car", "bus", "airplane",
                    "fork.knife", "cup.and.saucer", "wineglass",
                    "cross.case", "star", "person", "gamecontroller", "house", "cloud",
                    "film", "music.note", "book", "pawprint", "leaf", "lightbulb",
                    "hammer", "paintbrush", "wrench", "bed.double",
                    // из createCategory
                    "repeat", "creditcard", "spigot", "figure.cooldown"
                ]

        }
    }

    var colors: [String] {
        switch self {
            case .income:
                return [
                    "#FF1744", "#2979FF", "#00E676", "#FF9100", "#D500F9",
                    "#FF3D00", "#00B0FF", "#FFEA00", "#00C853", "#F50057",
                    "#651FFF", "#64DD17", "#C51162", "#00E5FF", "#AA00FF",
                    "#FF6D00", "#DD2C00", "#1DE9B6", "#76FF03", "#E040FB"
                ]

            case .wallet:
                return [
                    "#FFD600", "#FF1744", "#00E5FF", "#00E676", // новые из wallets
                    "#F50057", "#2979FF", "#FFEA00", "#AA00FF",
                    "#FF6D00", "#00C853", "#FF3D00", "#651FFF",
                    "#00BFA5", "#76FF03", "#D50000", "#1DE9B6",
                    "#C51162", "#FFAB00", "#DD2C00", "#18FFFF",
                    "#64DD17", "#E040FB"
                ]

            case .category:
                return [
                    "#FF3D00", "#D500F9", "#651FFF", "#00B0FF", "#2979FF", "#00E5FF",
                    "#FF9100", "#00E676", "#C6FF00", "#FF4081", "#FF6D00", "#AA00FF", // новые из categories
                    "#00C853", "#F50057", "#FF1744", "#FFEA00",
                    "#76FF03", "#C51162", "#1DE9B6", "#FFAB00",
                    "#DD2C00", "#18FFFF", "#E040FB"
                ]
        }
    }
}
