//
//  SettingsModel.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 07.01.2026.
//


import Foundation
import UIKit

public struct IconModel {
    public let title: String
    public let icon: UIImage
    public let isSelected: Bool
    public let isPremium: Bool

    public init(title: String, icon: UIImage, isSelected: Bool = false, isPremium: Bool) {
        self.title = title
        self.icon = icon
        self.isSelected = isSelected
        self.isPremium = isPremium
    }
}

public struct SettingsModel {
    public let title: String
    public let options: [SettingsOptionSection]
    public let appVersion: String?
    public let userId: String?
    public let agreementLink: URL?
    public let iosVersion: String

    public init(
        title: String,
        options: [SettingsOptionSection],
        iosVersion: String,
        appVersion: String?,
        userId: String?,
        agreementLink: URL?
    ) {
        self.title = title
        self.options = options
        self.iosVersion = iosVersion
        self.appVersion = appVersion
        self.userId = userId
        self.agreementLink = agreementLink
    }
}


public struct SettingsOptionSection {
    public let title: String
    public let options: [SettingsOption]

    public init(title: String, options: [SettingsOption]) {
        self.title = title
        self.options = options
    }
}

public struct SettingsOption {
    public let title: String
    public let option: SettingsEnum
    public let icon: String

    public init(title: String, option: SettingsEnum, icon: String) {
        self.title = title
        self.option = option
        self.icon = icon
    }
}

public enum SettingsEnum: String, CaseIterable {
    case termsAndConditions
    case privacy
    case icon
    case feedback
    case contactUs
    case appReviews
    case cancelSubscription
    case buySubscription
    case deleteAccount
    case signOut
    case promoCode
}

public enum ContactType {
    case telegram
    case whatsapp
    case email
}


public class SettingsProvider {
    let keychain = Keychain.shared
    private let keychainKey = "com.nursultan.MoneyCheck.userId"

    private let settingsTitle = String(localized: "Settings")
    private let termsAndConditionsLink = URL(string: "")

    public init() {}
}

extension SettingsProvider {
    public func settingsItem(completion: @escaping (SettingsModel) -> Void) {
        let userId = getOrCreateUserId()
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            completion(makeSettingsModel(userId: userId, appVersion: nil, iosVersion: UIDevice.current.systemVersion))
            return
        }
        completion(makeSettingsModel(userId: userId, appVersion: version, iosVersion: UIDevice.current.systemVersion))
    }

    public func changeAppIcon(to iconName: String?) {
        guard UIApplication.shared.supportsAlternateIcons else {
            return
        }

        UIApplication.shared.setAlternateIconName(iconName)
    }

    public func icons(completion: @escaping (Result<[IconModel], any Error>) -> Void) {
        let model = iconModels()
        completion(.success(model))
    }


    public func sendFeedback(feedback: String, completion: @escaping (Result<Void, any Error>) -> Void) {
        let userId = getOrCreateUserId()
        let feedbackId = UUID().uuidString

        let data: [String: Any] = [
            "feedback": feedback,
            "user_id": userId
        ]

//        Firestore.firestore()
//            .collection("feedback")
//            .document(feedbackId)
//            .setData(data) { error in
//                if let error = error {
//                    completion(.failure(error))
//                } else {
//                    completion(.success(()))
//                }
//            }
    }
}

private extension SettingsProvider {
    func makeFirstSectionOptions(hasSubscription: Bool) -> SettingsOptionSection {
        var options = [
            SettingsOption(title: String(localized: "Terms and Conditions"), option: .termsAndConditions, icon: "doc"),
            SettingsOption(title: String(localized: "Privacy"), option: .privacy, icon: "shield.lefthalf.filled.badge.checkmark"),
//            SettingsOption(title: String(localized: "Icon"), option: .icon, icon: "play.square"),
            SettingsOption(title: String(localized: "Feedback"), option: .feedback, icon: "bubble.right"),
            SettingsOption(title: String(localized: "Contact us"), option: .contactUs, icon: "phone"),
            SettingsOption(title: String(localized: "App reviews"), option: .appReviews, icon: "checkmark.seal"),
            SettingsOption(title: String(localized: "Promo Code"), option: .promoCode, icon: "gift")
        ]

        if hasSubscription {
            options.append(SettingsOption(title: String(localized: "Cancel subscription"), option: .cancelSubscription, icon: "creditcard.trianglebadge.exclamationmark"))
        } else {
            options.append(SettingsOption(title: String(localized: "Buy subscription"), option: .buySubscription, icon: "creditcard"))
        }

        return SettingsOptionSection(
            title: String(localized: "General"),
            options: options
        )
    }

    func makeSecondSectionOptions() -> SettingsOptionSection {
        return SettingsOptionSection(
            title: String(localized: "Account"),
            options: [SettingsOption(title: String(localized: "Delete account"), option: .deleteAccount, icon: "trash"),
                      SettingsOption(title: String(localized: "Sign out"), option: .signOut, icon: "door.left.hand.open")
        ])
    }

    func makeSettingsModel(userId: String?, appVersion: String?, iosVersion: String) -> SettingsModel {
        return SettingsModel(
            title: settingsTitle,
            options: [
                makeFirstSectionOptions(hasSubscription: false),
                makeSecondSectionOptions()
            ],
            iosVersion: iosVersion,
            appVersion: appVersion,
            userId: userId,
            agreementLink: termsAndConditionsLink
        )
    }

    func hasSubscription() -> Bool {
        //TODO: - return state from subscriptionService
        return false
    }

    func iconModels() -> [IconModel] {
        var iconModels = [IconModel]()
        var isSelected = false
        let standardImage = UIImage(named: "Standard") ?? UIImage()
        let premiumImage = UIImage(named: "Premium") ?? UIImage()

        if UIApplication.shared.alternateIconName != nil {
            isSelected = true
        } else {
            isSelected = false
        }
        iconModels = [
            IconModel(
                title: String(localized: "Standard"),
                icon: standardImage,
                isSelected: !isSelected,
                isPremium: false
            ),
            IconModel(
                title: String(localized: "Premium"),
                icon: premiumImage,
                isSelected: isSelected,
                isPremium: true
            )
        ]

        return iconModels
    }

    func getOrCreateUserId() -> String {
//        if let userId = Auth.auth().currentUser?.uid {
//            return userId
//        }

        if let storedId: String = keychain.get(forKey: keychainKey) {
            return storedId
        }

        let newUserId = UUID().uuidString
        keychain.save(newUserId, forKey: keychainKey)
        return newUserId
    }
}
