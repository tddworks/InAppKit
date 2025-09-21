//
//  ProductConfiguration.swift
//  InAppKit
//
//  Product configuration types and convenience functions
//

import Foundation
import SwiftUI
import StoreKit

// MARK: - Product Configuration Support

public struct ProductConfig<T: Hashable & Sendable>: Sendable {
    public let id: String
    public let features: [T]
    public let badge: String?
    public let marketingFeatures: [String]?
    public let savings: String?

    public init(
        _ id: String,
        features: [T],
        badge: String? = nil,
        marketingFeatures: [String]? = nil,
        savings: String? = nil
    ) {
        self.id = id
        self.features = features
        self.badge = badge
        self.marketingFeatures = marketingFeatures
        self.savings = savings
    }
}

// Convenience for AnyHashable
public struct InternalProductConfig: @unchecked Sendable {
    public let id: String
    public let features: [AnyHashable]
    public let badge: String?
    public let marketingFeatures: [String]?
    public let savings: String?

    public init(
        id: String,
        features: [AnyHashable],
        badge: String? = nil,
        marketingFeatures: [String]? = nil,
        savings: String? = nil
    ) {
        self.id = id
        self.features = features
        self.badge = badge
        self.marketingFeatures = marketingFeatures
        self.savings = savings
    }
}

// MARK: - Convenience Functions for Product Creation

// Simple product without features (most common case)
public func Product(_ id: String) -> ProductConfig<String> {
    ProductConfig(id, features: [])
}

// New fluent API convenience functions
public func Product<T: Hashable & Sendable>(_ id: String, features: [T]) -> ProductConfig<T> {
    ProductConfig(id, features: features)
}

// Product with marketing information
public func Product<T: Hashable & Sendable>(
    _ id: String,
    features: [T],
    badge: String? = nil,
    marketingFeatures: [String]? = nil,
    savings: String? = nil
) -> ProductConfig<T> {
    ProductConfig(
        id,
        features: features,
        badge: badge,
        marketingFeatures: marketingFeatures,
        savings: savings
    )
}

// Support for .allCases pattern - for when you pass [EnumType.allCases]
public func Product<T: CaseIterable & Hashable & Sendable>(_ id: String, _ allCases: T.AllCases) -> ProductConfig<T> {
    ProductConfig(id, features: Array(allCases))
}

// Direct array support for cleaner syntax
public func Product<T: Hashable & Sendable>(_ id: String, _ features: [T]) -> ProductConfig<T> {
    ProductConfig(id, features: features)
}

// MARK: - Fluent API Extensions for Marketing

public extension ProductConfig {
    /// Add a promotional badge to the product
    func withBadge(_ badge: String) -> ProductConfig<T> {
        ProductConfig(
            id,
            features: features,
            badge: badge,
            marketingFeatures: marketingFeatures,
            savings: savings
        )
    }

    /// Add marketing features (shown as bullet points in UI)
    func withMarketingFeatures(_ features: [String]) -> ProductConfig<T> {
        ProductConfig(
            id,
            features: self.features,
            badge: badge,
            marketingFeatures: features,
            savings: savings
        )
    }

    /// Add savings information
    func withSavings(_ savings: String) -> ProductConfig<T> {
        ProductConfig(
            id,
            features: features,
            badge: badge,
            marketingFeatures: marketingFeatures,
            savings: savings
        )
    }
}

// MARK: - PaywallContext

/// Context for product-based paywalls
public struct PaywallContext {
    public let triggeredBy: String?  // What action triggered the paywall
    public let availableProducts: [StoreKit.Product]  // Products that can be purchased
    public let recommendedProduct: StoreKit.Product?  // Best product to recommend
    
    public init(triggeredBy: String? = nil, availableProducts: [StoreKit.Product] = [], recommendedProduct: StoreKit.Product? = nil) {
        self.triggeredBy = triggeredBy
        self.availableProducts = availableProducts
        self.recommendedProduct = recommendedProduct ?? availableProducts.first
    }
}
