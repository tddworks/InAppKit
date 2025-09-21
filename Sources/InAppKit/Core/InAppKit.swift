//
//  InAppKit.swift
//  InAppKit
//
//  User-Centric InAppKit with Auto-Configuration
//

import Foundation
import StoreKit
import SwiftUI
import OSLog

@MainActor
@Observable
public class InAppKit {
    public static let shared = InAppKit()
    
    public var purchasedProductIDs: Set<String> = []
    public var availableProducts: [Product] = []
    public var isPurchasing = false
    public var purchaseError: Error?
    public var isInitialized = false
    
    // Feature-based configuration storage
    private var featureToProductMapping: [AnyHashable: [String]] = [:]
    private var productToFeatureMapping: [String: [AnyHashable]] = [:]
    private var productMarketingInfo: [String: (badge: String?, features: [String]?, savings: String?)] = [:]
    
    private var updateListenerTask: Task<Void, Error>?
    
    private init() {
        updateListenerTask = listenForTransactions()
        Task {
            await updatePurchasedProducts()
        }
    }
    
    deinit {
        // Task cleanup happens automatically
    }
    
    
    
    /// Initialize with product configurations (for fluent API)
    internal func initialize(with productConfigs: [InternalProductConfig]) async {
        let productIDs = productConfigs.map { $0.id }

        // Register features and marketing info
        for config in productConfigs {
            // Register features
            for feature in config.features {
                registerFeature(feature, productIds: [config.id])
            }

            // Store marketing information
            productMarketingInfo[config.id] = (
                badge: config.badge,
                features: config.marketingFeatures,
                savings: config.savings
            )
        }

        await loadProducts(productIds: productIDs)
        isInitialized = true
    }
    
    
    public func loadProducts(productIds: [String]) async {
        do {
            let products = try await Product.products(for: productIds)
            self.availableProducts = products
            Logger.statistics.info("Loaded \(products.count) products")
        } catch {
            Logger.statistics.error("Failed to load products: \(error.localizedDescription)")
            purchaseError = error
        }
    }
    
    public func purchase(_ product: Product) async throws {
        isPurchasing = true
        purchaseError = nil
        
        defer {
            isPurchasing = false
        }
        
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updatePurchasedProducts()
            await transaction.finish()
        case .userCancelled:
            break
        case .pending:
            break
        @unknown default:
            break
        }
    }
    
    public func restorePurchases() async {
        await updatePurchasedProducts()
    }
    
    public func isPurchased(_ productId: String) -> Bool {
        return purchasedProductIDs.contains(productId)
    }
    
    /// Check if user has any active purchases
    public var hasAnyPurchase: Bool {
        return !purchasedProductIDs.isEmpty
    }
    
    /// Legacy compatibility - use hasAnyPurchase instead
    @available(*, deprecated, message: "Use hasAnyPurchase for clearer semantics")
    public var isPremium: Bool {
        return hasAnyPurchase
    }
    
    
    /// Check if user has access to a specific feature
    public func hasAccess<F: Hashable>(to feature: F) -> Bool {
        return hasAccess(to: AnyHashable(feature))
    }

    /// Check if user has access to a feature (AnyHashable version)
    public func hasAccess(to feature: AnyHashable) -> Bool {
        let requiredProducts = featureToProductMapping[feature] ?? []

        // If no products mapped to this feature, fall back to any purchase check
        if requiredProducts.isEmpty {
            return hasAnyPurchase
        }

        return requiredProducts.contains { productId in
            purchasedProductIDs.contains(productId)
        }
    }
    
    /// Get products that provide a specific feature
    public func products<F: Hashable>(for feature: F) -> [Product] {
        let featureKey = AnyHashable(feature)
        let productIds = featureToProductMapping[featureKey] ?? []
        
        return availableProducts.filter { product in
            productIds.contains(product.id)
        }
    }
    
    /// Register a feature with its product IDs (used by configuration builder)
    public func registerFeature(_ feature: AnyHashable, productIds: [String]) {
        featureToProductMapping[feature] = productIds
        for productId in productIds {
            productToFeatureMapping[productId, default: []].append(feature)
        }
    }
    
    /// Check if a feature is registered (for validation)
    public func isFeatureRegistered<F: Hashable>(_ feature: F) -> Bool {
        return isFeatureRegistered(AnyHashable(feature))
    }

    /// Check if a feature is registered (AnyHashable version)
    public func isFeatureRegistered(_ feature: AnyHashable) -> Bool {
        return featureToProductMapping[feature] != nil
    }

    // MARK: - Marketing Information

    /// Get marketing badge for a product
    public func badge(for productId: String) -> String? {
        return productMarketingInfo[productId]?.badge
    }

    /// Get marketing features for a product
    public func marketingFeatures(for productId: String) -> [String]? {
        return productMarketingInfo[productId]?.features
    }

    /// Get savings information for a product
    public func savings(for productId: String) -> String? {
        return productMarketingInfo[productId]?.savings
    }
    
    // MARK: - Development Helpers
    
    #if DEBUG
    /// Development helper to simulate purchases
    public func simulatePurchase(_ productId: String) {
        purchasedProductIDs.insert(productId)
    }
    
    /// Development helper to clear purchases
    public func clearPurchases() {
        purchasedProductIDs.removeAll()
    }
    #endif
    
    // MARK: - Private Methods
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    private func updatePurchasedProducts() async {
        var purchasedProductIDs: Set<String> = []
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                switch transaction.productType {
                case .consumable:
                    break
                case .nonConsumable:
                    purchasedProductIDs.insert(transaction.productID)
                case .autoRenewable:
                    purchasedProductIDs.insert(transaction.productID)
                case .nonRenewable:
                    purchasedProductIDs.insert(transaction.productID)
                default:
                    break
                }
            } catch {
                Logger.statistics.error("Failed to verify transaction: \(error.localizedDescription)")
            }
        }
        
        self.purchasedProductIDs = purchasedProductIDs
    }
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task {
            for await result in Transaction.updates {
                do {
                    let transaction = try checkVerified(result)
                    await updatePurchasedProducts()
                    await transaction.finish()
                } catch {
                    Logger.statistics.error("Failed to verify transaction: \(error.localizedDescription)")
                }
            }
        }
    }
}

public enum StoreError: Error {
    case failedVerification
    case productNotFound(String)
    case purchaseInProgress
    case userCancelled
    case networkError(Error)
    case unknownError(Error)

    public var localizedDescription: String {
        switch self {
        case .failedVerification:
            return "Purchase verification failed. Please try again."
        case .productNotFound(let productId):
            return "Product '\(productId)' not found in App Store."
        case .purchaseInProgress:
            return "A purchase is already in progress."
        case .userCancelled:
            return "Purchase was cancelled by user."
        case .networkError:
            return "Network error occurred. Please check your connection."
        case .unknownError(let error):
            return "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
}
