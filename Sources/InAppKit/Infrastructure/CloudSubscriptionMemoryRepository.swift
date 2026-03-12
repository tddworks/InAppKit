//
//  CloudSubscriptionMemoryRepository.swift
//  InAppKit
//
//  iCloud KVS-backed subscription memory repository.
//  Syncs across devices via NSUbiquitousKeyValueStore.
//

import Foundation

public final class CloudSubscriptionMemoryRepository: SubscriptionMemoryRepository, @unchecked Sendable {

    private let key = "com.inappkit.subscription-memory"
    private let kvStore: NSUbiquitousKeyValueStore

    public init(kvStore: NSUbiquitousKeyValueStore = .default) {
        self.kvStore = kvStore
    }

    public func load() async throws -> SubscriptionMemory {
        guard let data = kvStore.data(forKey: key) else {
            return SubscriptionMemory()
        }
        return try JSONDecoder().decode(SubscriptionMemory.self, from: data)
    }

    public func save(_ memory: SubscriptionMemory) async throws {
        let data = try JSONEncoder().encode(memory)
        kvStore.set(data, forKey: key)
        kvStore.synchronize()
    }

    public func clear() async throws {
        kvStore.removeObject(forKey: key)
        kvStore.synchronize()
    }
}
