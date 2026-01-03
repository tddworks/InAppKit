//
//  MarketingRegistry.swift
//  InAppKit
//
//  Pure domain model for product marketing information.
//  No StoreKit dependency - 100% testable.
//

import SwiftUI

/// Marketing information for a product - pure value type
public struct ProductMarketing: Sendable {
    public let badge: String?
    public let badgeColor: Color?
    public let features: [String]?
    public let promoText: String?
    public let relativeDiscountConfig: RelativeDiscountConfig?

    public init(
        badge: String? = nil,
        badgeColor: Color? = nil,
        features: [String]? = nil,
        promoText: String? = nil,
        relativeDiscountConfig: RelativeDiscountConfig? = nil
    ) {
        self.badge = badge
        self.badgeColor = badgeColor
        self.features = features
        self.promoText = promoText
        self.relativeDiscountConfig = relativeDiscountConfig
    }

    // MARK: - Domain Behavior

    /// Whether this product has any marketing info configured
    public var hasMarketing: Bool {
        badge != nil || features != nil || promoText != nil
    }

    /// Whether this product has a promotional badge
    public var hasBadge: Bool {
        badge != nil
    }

    /// Whether this product has relative discount configured
    public var hasRelativeDiscount: Bool {
        relativeDiscountConfig != nil
    }
}

/// Registry for product marketing information - pure value type
public struct MarketingRegistry {
    private var marketingInfo: [String: ProductMarketing]

    public init() {
        self.marketingInfo = [:]
    }

    // MARK: - Queries

    /// Get marketing info for a product
    public func marketing(for productId: String) -> ProductMarketing? {
        marketingInfo[productId]
    }

    /// Get badge for a product
    public func badge(for productId: String) -> String? {
        marketingInfo[productId]?.badge
    }

    /// Get badge color for a product
    public func badgeColor(for productId: String) -> Color? {
        marketingInfo[productId]?.badgeColor
    }

    /// Get marketing features for a product
    public func features(for productId: String) -> [String]? {
        marketingInfo[productId]?.features
    }

    /// Get promo text for a product
    public func promoText(for productId: String) -> String? {
        marketingInfo[productId]?.promoText
    }

    /// Get relative discount config for a product
    public func relativeDiscountConfig(for productId: String) -> RelativeDiscountConfig? {
        marketingInfo[productId]?.relativeDiscountConfig
    }

    /// Get all product IDs with marketing info
    public var allProductIds: Set<String> {
        Set(marketingInfo.keys)
    }

    /// Get all products with badges
    public var productsWithBadges: [String] {
        marketingInfo.filter { $0.value.hasBadge }.map { $0.key }
    }

    // MARK: - Commands (return new state - immutable)

    /// Register marketing info for a product
    public func withMarketing(_ productId: String, marketing: ProductMarketing) -> MarketingRegistry {
        var newRegistry = self
        newRegistry.marketingInfo[productId] = marketing
        return newRegistry
    }

    /// Register marketing info from ProductConfig
    public func withMarketing(from config: InternalProductConfig) -> MarketingRegistry {
        let marketing = ProductMarketing(
            badge: config.badge,
            badgeColor: config.badgeColor,
            features: config.marketingFeatures,
            promoText: config.promoText,
            relativeDiscountConfig: config.relativeDiscountConfig
        )
        return withMarketing(config.id, marketing: marketing)
    }

    /// Register marketing info from multiple ProductConfigs
    public func withMarketing(from configs: [InternalProductConfig]) -> MarketingRegistry {
        var registry = self
        for config in configs {
            registry = registry.withMarketing(from: config)
        }
        return registry
    }

    /// Remove marketing info for a product
    public func withoutMarketing(for productId: String) -> MarketingRegistry {
        var newRegistry = self
        newRegistry.marketingInfo.removeValue(forKey: productId)
        return newRegistry
    }

    /// Clear all marketing info
    public func cleared() -> MarketingRegistry {
        MarketingRegistry()
    }
}
