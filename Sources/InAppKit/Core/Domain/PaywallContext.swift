//
//  PaywallContext.swift
//  InAppKit
//
//  Domain model for paywall presentation context.
//  "This is the context I need to show my paywall"
//

import Foundation
import StoreKit

/// Context for showing a paywall.
/// "When I show a paywall, I need to know what products are available"
public struct PaywallContext {
    /// What action triggered the paywall (e.g., "premium_feature", "export")
    public let triggeredBy: String?

    /// Products available for purchase
    public let availableProducts: [Product]

    /// Recommended product to highlight
    public let recommendedProduct: Product?

    public init(
        triggeredBy: String? = nil,
        availableProducts: [Product] = [],
        recommendedProduct: Product? = nil
    ) {
        self.triggeredBy = triggeredBy
        self.availableProducts = availableProducts
        self.recommendedProduct = recommendedProduct ?? availableProducts.first
    }

    // MARK: - Marketing Information Helpers

    /// Get marketing badge for a product
    @MainActor
    public func badge(for product: Product) -> String? {
        InAppKit.shared.badge(for: product.id)
    }

    /// Get marketing features for a product
    @MainActor
    public func marketingFeatures(for product: Product) -> [String]? {
        InAppKit.shared.marketingFeatures(for: product.id)
    }

    /// Get promotional text for a product
    @MainActor
    public func promoText(for product: Product) -> String? {
        InAppKit.shared.promoText(for: product.id)
    }

    /// Get all marketing information for a product
    @MainActor
    public func marketingInfo(for product: Product) -> (badge: String?, features: [String]?, promoText: String?) {
        (
            badge: badge(for: product),
            features: marketingFeatures(for: product),
            promoText: promoText(for: product)
        )
    }

    /// Get products with their marketing information
    @MainActor
    public var productsWithMarketing: [(product: Product, badge: String?, features: [String]?, promoText: String?)] {
        availableProducts.map { product in
            let info = marketingInfo(for: product)
            return (product: product, badge: info.badge, features: info.features, promoText: info.promoText)
        }
    }
}
