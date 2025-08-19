//
//  Feature.swift
//  InAppKit
//
//  A simple feature definition that maps app functionality to StoreKit products.
//  This provides a clean abstraction layer over raw product IDs.
//

import Foundation
import StoreKit

// MARK: - AppFeature Protocol

/// Protocol for type-safe feature definitions
/// 
/// Implement this protocol with an enum for type-safe feature gating:
/// ```swift
/// enum AppFeature: String, AppFeature {
///     case sync = "sync"
///     case export = "export"
///     case support = "premium_support"
/// }
/// ```
public protocol AppFeature: Hashable, CaseIterable {
    var rawValue: String { get }
}

// MARK: - AppFeature Extensions

// MARK: - InAppKit Extensions for AppFeature

public extension InAppKit {
    /// Check if user has access to an AppFeature
    func hasAccess<T: AppFeature>(to feature: T) -> Bool {
        return hasAccess(to: AnyHashable(feature.rawValue))
    }
    
    /// Get products that provide a specific AppFeature
    func products<T: AppFeature>(for feature: T) -> [Product] {
        return products(for: AnyHashable(feature.rawValue))
    }
    
    /// Register an AppFeature with its product IDs
    func registerFeature<T: AppFeature>(_ feature: T, productIds: [String]) {
        registerFeature(AnyHashable(feature.rawValue), productIds: productIds)
    }
    
    /// Check if an AppFeature is registered
    func isFeatureRegistered<T: AppFeature>(_ feature: T) -> Bool {
        return isFeatureRegistered(AnyHashable(feature.rawValue))
    }
}
