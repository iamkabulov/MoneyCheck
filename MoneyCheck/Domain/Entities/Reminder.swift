//
//  Reminder.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 10.01.2026.
//

import Foundation

struct Reminder {
    static let id: String = "daily_reminder"
    let title: String
    let body: String
    let hour: Int
    let minute: Int
    let isEnabled: Bool
}



struct StoredReminder {
    let isEnabled: Bool
    let time: Date?
    let title: String?
    let message: String?
}
