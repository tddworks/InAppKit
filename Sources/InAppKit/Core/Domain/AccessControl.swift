//
//  AccessControl.swift
//  InAppKit
//
//  Pure domain logic for access control decisions.
//  No StoreKit dependency - 100% testable.
//

import Foundation

/// Access control logic - pure functions operating on domain models
public enum AccessControl {

    /// Check if user has access to a feature
    /// - Parameters:
    ///   - feature: The feature to check access for
    ///   - purchaseState: Current purchase state
    ///   - featureRegistry: Feature to product mappings
    /// - Returns: true if user has access
    public static func hasAccess(
        to feature: AnyHashable,
        purchaseState: PurchaseState,
        featureRegistry: FeatureRegistry
    ) -> Bool {
        let requiredProducts = featureRegistry.productIds(for: feature)

        // Fallback: if no products mapped to this feature, check any purchase
        if requiredProducts.isEmpty {
            return purchaseState.hasAnyPurchase
        }

        // Check if user owns any of the required products
        return requiredProducts.contains { productId in
            purchaseState.isPurchased(productId)
        }
    }

    /// Check if user has access to an AppFeature
    public static func hasAccess<T: AppFeature>(
        to feature: T,
        purchaseState: PurchaseState,
        featureRegistry: FeatureRegistry
    ) -> Bool {
        hasAccess(
            to: AnyHashable(feature.rawValue),
            purchaseState: purchaseState,
            featureRegistry: featureRegistry
        )
    }

    /// Check access for multiple features at once
    public static func accessStatus(
        for features: [AnyHashable],
        purchaseState: PurchaseState,
        featureRegistry: FeatureRegistry
    ) -> [AnyHashable: Bool] {
        var result: [AnyHashable: Bool] = [:]
        for feature in features {
            result[feature] = hasAccess(
                to: feature,
                purchaseState: purchaseState,
                featureRegistry: featureRegistry
            )
        }
        return result
    }

    /// Get all features user has access to
    public static func accessibleFeatures(
        purchaseState: PurchaseState,
        featureRegistry: FeatureRegistry
    ) -> Set<AnyHashable> {
        featureRegistry.allFeatures.filter { feature in
            hasAccess(
                to: feature,
                purchaseState: purchaseState,
                featureRegistry: featureRegistry
            )
        }
    }

    /// Get features user is missing (doesn't have access to)
    public static func missingFeatures(
        purchaseState: PurchaseState,
        featureRegistry: FeatureRegistry
    ) -> Set<AnyHashable> {
        featureRegistry.allFeatures.filter { feature in
            !hasAccess(
                to: feature,
                purchaseState: purchaseState,
                featureRegistry: featureRegistry
            )
        }
    }
}
