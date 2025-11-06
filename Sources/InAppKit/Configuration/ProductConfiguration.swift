//
//  ProductConfiguration.swift
//  InAppKit
//
//  Product configuration types and convenience functions
//

import Foundation
import SwiftUI
import StoreKit
import OSLog

// MARK: - Relative Discount Configuration

/// Configuration for automatic relative discount calculation
public struct RelativeDiscountConfig: Sendable {
    public let baseProductId: String
    public let style: DiscountStyle
    public let color: Color?

    public init(baseProductId: String, style: DiscountStyle = .percentage, color: Color? = nil) {
        self.baseProductId = baseProductId
        self.style = style
        self.color = color
    }

    public enum DiscountStyle: Sendable {
        case percentage  // "31% off"
        case amount      // "Save $44"
        case freeTime    // "2 months free"
    }
}

// MARK: - Product Configuration Support

public protocol AnyProductConfig {
    var id: String { get }
    var badge: String? { get }
    var badgeColor: Color? { get }
    var marketingFeatures: [String]? { get }
    var promoText: String? { get }
    var relativeDiscountConfig: RelativeDiscountConfig? { get }
    func toInternal() -> InternalProductConfig
}

public struct ProductConfig<T: Hashable>: AnyProductConfig {
    public let id: String
    public let features: [T]
    public let badge: String?
    public let badgeColor: Color?
    public let marketingFeatures: [String]?
    public let promoText: String?
    public let relativeDiscountConfig: RelativeDiscountConfig?

    public init(
        _ id: String,
        features: [T],
        badge: String? = nil,
        badgeColor: Color? = nil,
        marketingFeatures: [String]? = nil,
        promoText: String? = nil,
        relativeDiscountConfig: RelativeDiscountConfig? = nil
    ) {
        self.id = id
        self.features = features
        self.badge = badge
        self.badgeColor = badgeColor
        self.marketingFeatures = marketingFeatures
        self.promoText = promoText
        self.relativeDiscountConfig = relativeDiscountConfig
    }

    public func toInternal() -> InternalProductConfig {
        #if DEBUG
        if let config = relativeDiscountConfig {
            Logger.statistics.debug("🟢 toInternal() preserving relativeDiscountConfig for \(self.id): \(config.baseProductId)")
        }
        #endif

        return InternalProductConfig(
            id: id,
            features: features.map { AnyHashable($0) },
            badge: badge,
            badgeColor: badgeColor,
            marketingFeatures: marketingFeatures,
            promoText: promoText,
            relativeDiscountConfig: relativeDiscountConfig
        )
    }
}

// Convenience for AnyHashable
public struct InternalProductConfig: @unchecked Sendable {
    public let id: String
    public let features: [AnyHashable]
    public let badge: String?
    public let badgeColor: Color?
    public let marketingFeatures: [String]?
    public let promoText: String?
    public let relativeDiscountConfig: RelativeDiscountConfig?

    public init(
        id: String,
        features: [AnyHashable],
        badge: String? = nil,
        badgeColor: Color? = nil,
        marketingFeatures: [String]? = nil,
        promoText: String? = nil,
        relativeDiscountConfig: RelativeDiscountConfig? = nil
    ) {
        self.id = id
        self.features = features
        self.badge = badge
        self.badgeColor = badgeColor
        self.marketingFeatures = marketingFeatures
        self.promoText = promoText
        self.relativeDiscountConfig = relativeDiscountConfig
    }
}

// MARK: - Convenience Functions for Product Creation

// Simple product without features (most common case)
public func Product(_ id: String) -> ProductConfig<String> {
    ProductConfig(id, features: [])
}

// New fluent API convenience functions
public func Product<T: Hashable>(_ id: String, features: [T]) -> ProductConfig<T> {
    ProductConfig(id, features: features)
}

// Support for .allCases with features: label (consistent API)
public func Product<T: CaseIterable & Hashable>(_ id: String, features allCases: T.AllCases) -> ProductConfig<T> {
    ProductConfig(id, features: Array(allCases))
}

// MARK: - Fluent API Extensions for Marketing

public extension ProductConfig {
    /// Add a promotional badge to the product
    func withBadge(_ badge: String) -> ProductConfig<T> {
        ProductConfig(
            id,
            features: features,
            badge: badge,
            badgeColor: badgeColor,
            marketingFeatures: marketingFeatures,
            promoText: promoText,
            relativeDiscountConfig: relativeDiscountConfig
        )
    }

    /// Add a promotional badge with custom color
    func withBadge(_ badge: String, color: Color) -> ProductConfig<T> {
        ProductConfig(
            id,
            features: features,
            badge: badge,
            badgeColor: color,
            marketingFeatures: marketingFeatures,
            promoText: promoText,
            relativeDiscountConfig: relativeDiscountConfig
        )
    }

    /// Add marketing features (shown as bullet points in UI)
    func withMarketingFeatures(_ features: [String]) -> ProductConfig<T> {
        ProductConfig(
            id,
            features: self.features,
            badge: badge,
            badgeColor: badgeColor,
            marketingFeatures: features,
            promoText: promoText,
            relativeDiscountConfig: relativeDiscountConfig
        )
    }

    /// Add promotional text to highlight the product
    /// - Parameter text: Custom promotional message (e.g., "Save $44", "Limited Time", "Best Value!")
    /// - Returns: Updated product configuration
    ///
    /// Example:
    /// ```swift
    /// Product("yearly", features: features)
    ///     .withPromoText("Save $44")
    /// ```
    func withPromoText(_ text: String) -> ProductConfig<T> {
        ProductConfig(
            id,
            features: features,
            badge: badge,
            badgeColor: badgeColor,
            marketingFeatures: marketingFeatures,
            promoText: text,
            relativeDiscountConfig: relativeDiscountConfig
        )
    }

    /// Add automatic relative discount calculation
    /// - Parameters:
    ///   - baseProductId: The product ID to compare against (e.g., monthly when this is yearly)
    ///   - style: How to display the discount (percentage, amount, or free time)
    ///   - color: Custom color for the discount text (defaults to orange if not specified)
    /// - Returns: Updated product configuration
    ///
    /// Example:
    /// ```swift
    /// Product("yearly", features: features)
    ///     .withRelativeDiscount(comparedTo: "monthly", style: .percentage, color: .green)
    /// // Displays: "Save 31%" in green (calculated automatically)
    /// ```
    func withRelativeDiscount(comparedTo baseProductId: String, style: RelativeDiscountConfig.DiscountStyle = .percentage, color: Color? = nil) -> ProductConfig<T> {
        let config = RelativeDiscountConfig(baseProductId: baseProductId, style: style, color: color)

        #if DEBUG
        Logger.statistics.debug("🔵 Creating ProductConfig with relativeDiscount: \(self.id) -> \(baseProductId)")
        #endif

        return ProductConfig(
            id,
            features: features,
            badge: badge,
            badgeColor: badgeColor,
            marketingFeatures: marketingFeatures,
            promoText: promoText,
            relativeDiscountConfig: config
        )
    }
}

// MARK: - PaywallContext

/// Context for product-based paywalls with marketing information
public struct PaywallContext {
    public let triggeredBy: String?  // What action triggered the paywall
    public let availableProducts: [StoreKit.Product]  // Products that can be purchased
    public let recommendedProduct: StoreKit.Product?  // Best product to recommend

    public init(triggeredBy: String? = nil, availableProducts: [StoreKit.Product] = [], recommendedProduct: StoreKit.Product? = nil) {
        self.triggeredBy = triggeredBy
        self.availableProducts = availableProducts
        self.recommendedProduct = recommendedProduct ?? availableProducts.first
    }

    // MARK: - Marketing Information Helpers

    /// Get marketing badge for a product
    @MainActor
    public func badge(for product: StoreKit.Product) -> String? {
        return InAppKit.shared.badge(for: product.id)
    }

    /// Get marketing features for a product
    @MainActor
    public func marketingFeatures(for product: StoreKit.Product) -> [String]? {
        return InAppKit.shared.marketingFeatures(for: product.id)
    }

    /// Get promotional text for a product
    @MainActor
    public func promoText(for product: StoreKit.Product) -> String? {
        return InAppKit.shared.promoText(for: product.id)
    }

    /// Get all marketing information for a product
    @MainActor
    public func marketingInfo(for product: StoreKit.Product) -> (badge: String?, features: [String]?, promoText: String?) {
        return (
            badge: badge(for: product),
            features: marketingFeatures(for: product),
            promoText: promoText(for: product)
        )
    }

    /// Get products with their marketing information
    @MainActor
    public var productsWithMarketing: [(product: StoreKit.Product, badge: String?, features: [String]?, promoText: String?)] {
        return availableProducts.map { product in
            let info = marketingInfo(for: product)
            return (product: product, badge: info.badge, features: info.features, promoText: info.promoText)
        }
    }
}
