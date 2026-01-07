//
//  KeychainProvider.swift
//  MoneyCheck
//
//  Created by Нурсултан Кабулов on 07.01.2026.
//


import Foundation

final class Keychain {
    static let shared = Keychain()

    private init() {}

    func save<T: Codable>(_ value: T, forKey key: String) {
        let data = try? JSONEncoder().encode(value)
        guard let data = data else { return }

        self.delete(forKey: key)

        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        SecItemAdd(addQuery as CFDictionary, nil)
    }

    func get<T: Codable>(forKey key: String) -> T? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess, let data = result as? Data else {
            return nil
        }

        return try? JSONDecoder().decode(T.self, from: data)
    }

    func delete(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        SecItemDelete(query as CFDictionary)
    }
}
