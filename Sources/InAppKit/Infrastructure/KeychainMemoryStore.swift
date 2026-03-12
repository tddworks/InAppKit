//
//  KeychainMemoryStore.swift
//  InAppKit
//
//  Keychain-backed subscription memory store.
//  Survives app reinstalls, device-only (not synced).
//

import Foundation
import Security

public final class KeychainMemoryStore: SubscriptionMemoryStore, @unchecked Sendable {

    private let service = "com.inappkit.subscription-memory"
    private let account = "subscription-memory"

    public init() {}

    public func load() async throws -> SubscriptionMemory {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess, let data = result as? Data else {
            if status == errSecItemNotFound {
                return SubscriptionMemory()
            }
            throw KeychainError.readFailed(status)
        }

        return try JSONDecoder().decode(SubscriptionMemory.self, from: data)
    }

    public func save(_ memory: SubscriptionMemory) async throws {
        let data = try JSONEncoder().encode(memory)

        // Try to update existing item first
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]

        let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

        if updateStatus == errSecItemNotFound {
            // Item doesn't exist, add it
            var addQuery = query
            addQuery[kSecValueData as String] = data
            addQuery[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock

            let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
            guard addStatus == errSecSuccess else {
                throw KeychainError.writeFailed(addStatus)
            }
        } else if updateStatus != errSecSuccess {
            throw KeychainError.writeFailed(updateStatus)
        }
    }

    public func clear() async throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status)
        }
    }
}

public enum KeychainError: Error {
    case readFailed(OSStatus)
    case writeFailed(OSStatus)
    case deleteFailed(OSStatus)
}
