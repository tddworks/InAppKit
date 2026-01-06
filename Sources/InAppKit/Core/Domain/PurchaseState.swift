//
//  PurchaseState.swift
//  InAppKit
//
//  Pure domain model for tracking purchase state.
//  No StoreKit dependency - 100% testable.
//

import Foundation

/// Represents the current purchase state - pure value type
public struct PurchaseState: Equatable, Sendable {
    public private(set) var purchasedProductIDs: Set<String>

    public init(purchasedProductIDs: Set<String> = []) {
        self.purchasedProductIDs = purchasedProductIDs
    }

    // MARK: - Queries

    /// Check if user has any active purchases
    public var hasAnyPurchase: Bool {
        !purchasedProductIDs.isEmpty
    }

    /// Check if a specific product is purchased
    public func isPurchased(_ productId: String) -> Bool {
        purchasedProductIDs.contains(productId)
    }

    // MARK: - Commands (return new state - immutable)

    /// Add a purchased product
    public func withPurchase(_ productId: String) -> PurchaseState {
        var newIDs = purchasedProductIDs
        newIDs.insert(productId)
        return PurchaseState(purchasedProductIDs: newIDs)
    }

    /// Add multiple purchased products
    public func withPurchases(_ productIds: Set<String>) -> PurchaseState {
        PurchaseState(purchasedProductIDs: purchasedProductIDs.union(productIds))
    }

    /// Remove a purchase (e.g., subscription expired)
    public func withoutPurchase(_ productId: String) -> PurchaseState {
        var newIDs = purchasedProductIDs
        newIDs.remove(productId)
        return PurchaseState(purchasedProductIDs: newIDs)
    }

    /// Clear all purchases
    public func cleared() -> PurchaseState {
        PurchaseState(purchasedProductIDs: [])
    }
}
