//
//  InAppKit.swift
//  InAppKit
//
//  User-Centric InAppKit with Auto-Configuration.
//  Delegates to pure domain models and uses Store for infrastructure.
//

import Foundation
import StoreKit
import SwiftUI
import OSLog

@Observable
@MainActor
public class InAppKit {
    public static let shared = InAppKit()

    // MARK: - Domain Models (Pure, Testable)

    private var purchaseState: PurchaseState = PurchaseState()
    private var featureRegistry: FeatureRegistry = FeatureRegistry()
    private var marketingRegistry: MarketingRegistry = MarketingRegistry()

    // MARK: - Infrastructure (Store)

    /// The store - where products are purchased
    private let store: any Store

    // MARK: - StoreKit State

    public var availableProducts: [Product] = []
    public var isPurchasing = false
    public var purchaseError: Error?
    public var isInitialized = false

    private var updateListenerTask: Task<Void, Error>?

    // MARK: - Public Accessors (Delegates to Domain Models)

    public var purchasedProductIDs: Set<String> {
        purchaseState.purchasedProductIDs
    }

    public var hasAnyPurchase: Bool {
        purchaseState.hasAnyPurchase
    }

    @available(*, deprecated, message: "Use hasAnyPurchase for clearer semantics")
    public var isPremium: Bool {
        hasAnyPurchase
    }

    // MARK: - Initialization

    /// Creates InAppKit with the real AppStore
    private init() {
        self.store = AppStore()
        updateListenerTask = listenForTransactions()
        Task {
            await refreshPurchases()
        }
    }

    /// Creates InAppKit with a custom Store (for testing)
    internal init(store: any Store) {
        self.store = store
        updateListenerTask = listenForTransactions()
        Task {
            await refreshPurchases()
        }
    }

    #if DEBUG
    /// Reset shared instance with a mock store (for testing)
    public static func configure(with store: any Store) -> InAppKit {
        return InAppKit(store: store)
    }
    #endif

    deinit {
        // Task cleanup happens automatically
    }

    // MARK: - Configuration

    internal func initialize(with productConfigs: [InternalProductConfig]) async {
        let productIDs = productConfigs.map { $0.id }

        // Register features using domain model
        for config in productConfigs {
            for feature in config.features {
                featureRegistry = featureRegistry.withFeature(feature, productIds: [config.id])
            }
        }

        // Register marketing info using domain model
        marketingRegistry = marketingRegistry.withMarketing(from: productConfigs)

        #if DEBUG
        for config in productConfigs {
            if let discountConfig = config.relativeDiscountConfig {
                Logger.statistics.info("📊 Stored relativeDiscountConfig for \(config.id): comparing to \(discountConfig.baseProductId), style: \(String(describing: discountConfig.style))")
            }
        }
        #endif

        await loadProducts(productIds: productIDs)
        isInitialized = true
    }

    // MARK: - Store Operations (Delegates to Store)

    public func loadProducts(productIds: [String]) async {
        do {
            let products = try await store.products(for: Set(productIds))
            self.availableProducts = products
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

        let outcome = try await store.purchase(product)

        switch outcome {
        case .success:
            await refreshPurchases()
        case .cancelled, .pending:
            break
        }
    }

    public func restorePurchases() async {
        do {
            let restored = try await store.restore()
            purchaseState = PurchaseState(purchasedProductIDs: restored)
        } catch {
            Logger.statistics.error("Failed to restore: \(error.localizedDescription)")
            purchaseError = error
        }
    }

    // MARK: - Purchase State (Delegates to PurchaseState)

    public func isPurchased(_ productId: String) -> Bool {
        purchaseState.isPurchased(productId)
    }

    // MARK: - Feature Access (Delegates to AccessControl)

    public func hasAccess<F: Hashable>(to feature: F) -> Bool {
        hasAccess(to: AnyHashable(feature))
    }

    public func hasAccess(to feature: AnyHashable) -> Bool {
        AccessControl.hasAccess(
            to: feature,
            purchaseState: purchaseState,
            featureRegistry: featureRegistry
        )
    }

    public func products<F: Hashable>(for feature: F) -> [Product] {
        let featureKey = AnyHashable(feature)
        let productIds = featureRegistry.productIds(for: featureKey)

        return availableProducts.filter { product in
            productIds.contains(product.id)
        }
    }

    // MARK: - Feature Registration (Delegates to FeatureRegistry)

    public func registerFeature(_ feature: AnyHashable, productIds: [String]) {
        featureRegistry = featureRegistry.withFeature(feature, productIds: productIds)
    }

    public func isFeatureRegistered<F: Hashable>(_ feature: F) -> Bool {
        isFeatureRegistered(AnyHashable(feature))
    }

    public func isFeatureRegistered(_ feature: AnyHashable) -> Bool {
        featureRegistry.isRegistered(feature)
    }

    // MARK: - Marketing Information (Delegates to MarketingRegistry)

    public func badge(for productId: String) -> String? {
        marketingRegistry.badge(for: productId)
    }

    public func badgeColor(for productId: String) -> Color? {
        marketingRegistry.badgeColor(for: productId)
    }

    public func marketingFeatures(for productId: String) -> [String]? {
        marketingRegistry.features(for: productId)
    }

    public func promoText(for productId: String) -> String? {
        marketingRegistry.promoText(for: productId)
    }

    public func relativeDiscountConfig(for productId: String) -> RelativeDiscountConfig? {
        marketingRegistry.relativeDiscountConfig(for: productId)
    }

    // MARK: - Development Helpers

    #if DEBUG
    public func simulatePurchase(_ productId: String) {
        purchaseState = purchaseState.withPurchase(productId)
    }

    public func clearPurchases() {
        purchaseState = purchaseState.cleared()
    }

    public func clearFeatures() {
        featureRegistry = FeatureRegistry()
    }

    public func clearMarketing() {
        marketingRegistry = MarketingRegistry()
    }
    #endif

    // MARK: - Private Methods

    private func refreshPurchases() async {
        do {
            let purchased = try await store.purchases()
            purchaseState = PurchaseState(purchasedProductIDs: purchased)
        } catch {
            Logger.statistics.error("Failed to refresh purchases: \(error.localizedDescription)")
        }
    }

    private func listenForTransactions() -> Task<Void, Error> {
        return Task {
            for await result in Transaction.updates {
                do {
                    let transaction = try checkVerified(result)
                    await refreshPurchases()
                    await transaction.finish()
                } catch {
                    Logger.statistics.error("Failed to verify transaction: \(error.localizedDescription)")
                }
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}

// MARK: - Store Error

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
