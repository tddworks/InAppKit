//
//  ProductDefinition.swift
//  InAppKit
//
//  Domain model for defining products to sell.
//  "I'm defining what products I want to sell in my app"
//

import Foundation
import SwiftUI
import StoreKit
import OSLog

// MARK: - Discount Rule

/// Rule for calculating relative discounts between products.
/// "I want to show how much users save with yearly vs monthly"
public struct DiscountRule: Sendable {
    public let comparedTo: String  // base product ID
    public let style: Style
    public let color: Color?

    public init(comparedTo baseProductId: String, style: Style = .percentage, color: Color? = nil) {
        self.comparedTo = baseProductId
        self.style = style
        self.color = color
    }

    public enum Style: Sendable {
        case percentage  // "31% off"
        case amount      // "Save $44"
        case freeTime    // "2 months free"
    }
}

// MARK: - Product Definition

/// Defines a product I want to sell.
/// "This is a product with these features and this marketing info"
public struct ProductDefinition: @unchecked Sendable {
    public let id: String
    public let features: [AnyHashable]
    public let badge: String?
    public let badgeColor: Color?
    public let marketingFeatures: [String]?
    public let promoText: String?
    public let discountRule: DiscountRule?

    public init(
        _ id: String,
        features: [AnyHashable] = [],
        badge: String? = nil,
        badgeColor: Color? = nil,
        marketingFeatures: [String]? = nil,
        promoText: String? = nil,
        discountRule: DiscountRule? = nil
    ) {
        self.id = id
        self.features = features
        self.badge = badge
        self.badgeColor = badgeColor
        self.marketingFeatures = marketingFeatures
        self.promoText = promoText
        self.discountRule = discountRule
    }
}

// MARK: - Product() Convenience Functions

/// Create a product without features
public func Product(_ id: String) -> ProductDefinition {
    ProductDefinition(id, features: [])
}

/// Create a product with features (type-safe)
public func Product<T: Hashable>(_ id: String, features: [T]) -> ProductDefinition {
    ProductDefinition(id, features: features.map { AnyHashable($0) })
}

/// Create a product with all cases of a feature enum (type-safe)
public func Product<T: CaseIterable & Hashable>(_ id: String, features: T.Type) -> ProductDefinition {
    ProductDefinition(id, features: T.allCases.map { AnyHashable($0) })
}

// MARK: - Fluent API Extensions

public extension ProductDefinition {
    /// Add a promotional badge
    func withBadge(_ badge: String) -> ProductDefinition {
        ProductDefinition(
            id, features: features, badge: badge, badgeColor: badgeColor,
            marketingFeatures: marketingFeatures, promoText: promoText, discountRule: discountRule
        )
    }

    /// Add a promotional badge with custom color
    func withBadge(_ badge: String, color: Color) -> ProductDefinition {
        ProductDefinition(
            id, features: features, badge: badge, badgeColor: color,
            marketingFeatures: marketingFeatures, promoText: promoText, discountRule: discountRule
        )
    }

    /// Add marketing features (bullet points in UI)
    func withMarketingFeatures(_ features: [String]) -> ProductDefinition {
        ProductDefinition(
            id, features: self.features, badge: badge, badgeColor: badgeColor,
            marketingFeatures: features, promoText: promoText, discountRule: discountRule
        )
    }

    /// Add promotional text
    func withPromoText(_ text: String) -> ProductDefinition {
        ProductDefinition(
            id, features: features, badge: badge, badgeColor: badgeColor,
            marketingFeatures: marketingFeatures, promoText: text, discountRule: discountRule
        )
    }

    /// Add relative discount calculation
    func withRelativeDiscount(comparedTo baseProductId: String, style: DiscountRule.Style = .percentage, color: Color? = nil) -> ProductDefinition {
        let rule = DiscountRule(comparedTo: baseProductId, style: style, color: color)

        #if DEBUG
        Logger.statistics.debug("🔵 Creating ProductDefinition with discount: \(self.id) -> \(baseProductId)")
        #endif

        return ProductDefinition(
            id, features: features, badge: badge, badgeColor: badgeColor,
            marketingFeatures: marketingFeatures, promoText: promoText, discountRule: rule
        )
    }
}
