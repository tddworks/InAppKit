//
//  SubscriptionMemory.swift
//  InAppKit
//
//  Immutable value type storing remembered subscriptions with expiry.
//  Pure domain model - no external dependencies.
//

import Foundation

public struct RememberedSubscription: Equatable, Sendable, Codable {
    public let productId: String
    public let rememberedAt: Date
    public let gracePeriod: TimeInterval

    public var expiresAt: Date {
        rememberedAt.addingTimeInterval(gracePeriod)
    }

    public init(productId: String, rememberedAt: Date, gracePeriod: TimeInterval) {
        self.productId = productId
        self.rememberedAt = rememberedAt
        self.gracePeriod = gracePeriod
    }

    public func isValid(at date: Date) -> Bool {
        date < expiresAt
    }
}

public struct SubscriptionMemory: Equatable, Sendable, Codable {
    public private(set) var subscriptions: [String: RememberedSubscription]

    public init(subscriptions: [String: RememberedSubscription] = [:]) {
        self.subscriptions = subscriptions
    }

    // MARK: - Queries

    public func validProductIDs(at date: Date) -> Set<String> {
        Set(subscriptions.values.filter { $0.isValid(at: date) }.map(\.productId))
    }

    public func isRemembered(_ productId: String, at date: Date) -> Bool {
        subscriptions[productId]?.isValid(at: date) ?? false
    }

    public func hasAnyMemory(at date: Date) -> Bool {
        subscriptions.values.contains { $0.isValid(at: date) }
    }

    // MARK: - Commands (immutable)

    public func withRemembered(_ productId: String, at date: Date, gracePeriod: TimeInterval) -> SubscriptionMemory {
        var newSubs = subscriptions
        newSubs[productId] = RememberedSubscription(
            productId: productId,
            rememberedAt: date,
            gracePeriod: gracePeriod
        )
        return SubscriptionMemory(subscriptions: newSubs)
    }

    public func withRemembered(_ productIds: Set<String>, at date: Date, gracePeriod: TimeInterval) -> SubscriptionMemory {
        var result = self
        for id in productIds {
            result = result.withRemembered(id, at: date, gracePeriod: gracePeriod)
        }
        return result
    }

    public func withoutMemory(_ productId: String) -> SubscriptionMemory {
        var newSubs = subscriptions
        newSubs.removeValue(forKey: productId)
        return SubscriptionMemory(subscriptions: newSubs)
    }

    public func pruned(at date: Date) -> SubscriptionMemory {
        let valid = subscriptions.filter { $0.value.isValid(at: date) }
        return SubscriptionMemory(subscriptions: valid)
    }

    public func cleared() -> SubscriptionMemory {
        SubscriptionMemory()
    }
}
