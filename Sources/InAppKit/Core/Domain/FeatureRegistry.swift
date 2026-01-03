//
//  FeatureRegistry.swift
//  InAppKit
//
//  Pure domain model for feature-to-product mappings.
//  No StoreKit dependency - 100% testable.
//

import Foundation

/// Registry for mapping features to product IDs - pure value type
public struct FeatureRegistry: Equatable {
    private var featureToProducts: [AnyHashable: Set<String>]
    private var productToFeatures: [String: Set<AnyHashable>]

    public init() {
        self.featureToProducts = [:]
        self.productToFeatures = [:]
    }

    // MARK: - Queries

    /// Check if a feature is registered
    public func isRegistered(_ feature: AnyHashable) -> Bool {
        featureToProducts[feature] != nil
    }

    /// Get product IDs that provide a feature
    public func productIds(for feature: AnyHashable) -> Set<String> {
        featureToProducts[feature] ?? []
    }

    /// Get features provided by a product
    public func features(for productId: String) -> Set<AnyHashable> {
        productToFeatures[productId] ?? []
    }

    /// Get all registered features
    public var allFeatures: Set<AnyHashable> {
        Set(featureToProducts.keys)
    }

    /// Get all registered product IDs
    public var allProductIds: Set<String> {
        Set(productToFeatures.keys)
    }

    // MARK: - Commands (return new state - immutable)

    /// Register a feature with product IDs
    public func withFeature(_ feature: AnyHashable, productIds: [String]) -> FeatureRegistry {
        var newRegistry = self

        // Update feature -> products mapping
        let existingProducts = newRegistry.featureToProducts[feature] ?? []
        newRegistry.featureToProducts[feature] = existingProducts.union(productIds)

        // Update product -> features mapping (bidirectional)
        for productId in productIds {
            let existingFeatures = newRegistry.productToFeatures[productId] ?? []
            newRegistry.productToFeatures[productId] = existingFeatures.union([feature])
        }

        return newRegistry
    }

    /// Register multiple features at once
    public func withFeatures(_ mappings: [(feature: AnyHashable, productIds: [String])]) -> FeatureRegistry {
        var registry = self
        for mapping in mappings {
            registry = registry.withFeature(mapping.feature, productIds: mapping.productIds)
        }
        return registry
    }
}

// MARK: - AppFeature Convenience

public extension FeatureRegistry {
    /// Register an AppFeature with product IDs
    func withFeature<T: AppFeature>(_ feature: T, productIds: [String]) -> FeatureRegistry {
        withFeature(AnyHashable(feature.rawValue), productIds: productIds)
    }

    /// Check if an AppFeature is registered
    func isRegistered<T: AppFeature>(_ feature: T) -> Bool {
        isRegistered(AnyHashable(feature.rawValue))
    }

    /// Get product IDs for an AppFeature
    func productIds<T: AppFeature>(for feature: T) -> Set<String> {
        productIds(for: AnyHashable(feature.rawValue))
    }
}
