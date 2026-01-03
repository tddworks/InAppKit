//
//  AppStore.swift
//  InAppKit
//
//  Real Store implementation using StoreKitProvider.
//  Delegates to StoreKitProvider for actual Apple API calls.
//  This makes AppStore itself testable with MockStoreKitProvider.
//

import StoreKit
import OSLog

/// Real Store implementation.
/// Uses StoreKitProvider for actual StoreKit calls (testable via DI).
public final class AppStore: Store, @unchecked Sendable {

    private let provider: any StoreKitProvider

    /// Creates AppStore with real StoreKit
    public init() {
        self.provider = DefaultStoreKitProvider()
    }

    /// Creates AppStore with custom provider (for testing)
    public init(provider: any StoreKitProvider) {
        self.provider = provider
    }

    // MARK: - Store Protocol

    public func products(for ids: Set<String>) async throws -> [Product] {
        let products = try await provider.fetchProducts(for: ids)
        Logger.statistics.info("Loaded \(products.count) products")
        return products
    }

    public func purchase(_ product: Product) async throws -> PurchaseOutcome {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            Logger.statistics.info("Purchase successful: \(product.id)")
            return .success(productId: product.id)

        case .userCancelled:
            return .cancelled

        case .pending:
            return .pending

        @unknown default:
            return .cancelled
        }
    }

    public func purchases() async throws -> Set<String> {
        var purchased: Set<String> = []

        let entitlements = try await provider.currentEntitlements()
        for result in entitlements {
            let transaction = try checkVerified(result)

            switch transaction.productType {
            case .consumable:
                break
            case .nonConsumable, .autoRenewable, .nonRenewable:
                purchased.insert(transaction.productID)
            default:
                break
            }
        }

        Logger.statistics.info("Found \(purchased.count) purchases")
        return purchased
    }

    public func restore() async throws -> Set<String> {
        try await provider.sync()
        return try await purchases()
    }

    // MARK: - Private

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}
