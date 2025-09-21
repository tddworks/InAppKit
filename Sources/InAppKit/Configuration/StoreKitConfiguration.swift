//
//  StoreKitConfiguration.swift
//  InAppKit
//
//  Fluent API for StoreKit configuration with chainable methods
//

import Foundation
import SwiftUI
import StoreKit

// MARK: - Fluent Configuration API

@MainActor
public class StoreKitConfiguration {
    internal var productConfigs: [InternalProductConfig] = []
    internal var paywallBuilder: ((PaywallContext) -> AnyView)?
    internal var termsBuilder: (() -> AnyView)?
    internal var privacyBuilder: (() -> AnyView)?
    
    public init() {}
    
    // MARK: - Fluent API Methods
    
    /// Configure purchases with minimal setup
    public func withPurchases(_ productId: String) -> StoreKitConfiguration {
        let config = InternalProductConfig(id: productId, features: [])
        productConfigs.append(config)
        return self
    }

    /// Configure purchases with multiple product IDs (variadic)
    public func withPurchases(_ productIds: String...) -> StoreKitConfiguration {
        let configs = productIds.map { InternalProductConfig(id: $0, features: []) }
        productConfigs.append(contentsOf: configs)
        return self
    }
    
    /// Configure purchases with features
    public func withPurchases<T: Hashable & Sendable>(products: [ProductConfig<T>]) -> StoreKitConfiguration {
        productConfigs.append(contentsOf: products.map {
            InternalProductConfig(
                id: $0.id,
                features: $0.features.map(AnyHashable.init),
                badge: $0.badge,
                marketingFeatures: $0.marketingFeatures,
                savings: $0.savings
            )
        })
        return self
    }

    /// Configure purchases with simple products (no features)
    public func withPurchases(products: [ProductConfig<String>]) -> StoreKitConfiguration {
        productConfigs.append(contentsOf: products.map {
            InternalProductConfig(
                id: $0.id,
                features: [],
                badge: $0.badge,
                marketingFeatures: $0.marketingFeatures,
                savings: $0.savings
            )
        })
        return self
    }
    
    /// Configure custom paywall
    public func withPaywall<Content: View>(@ViewBuilder _ builder: @escaping (PaywallContext) -> Content) -> StoreKitConfiguration {
        paywallBuilder = { context in AnyView(builder(context)) }
        return self
    }
    
    /// Configure terms view
    public func withTerms<Content: View>(@ViewBuilder _ builder: @escaping () -> Content) -> StoreKitConfiguration {
        termsBuilder = { AnyView(builder()) }
        return self
    }
    
    /// Configure privacy view
    public func withPrivacy<Content: View>(@ViewBuilder _ builder: @escaping () -> Content) -> StoreKitConfiguration {
        privacyBuilder = { AnyView(builder()) }
        return self
    }
    
    // MARK: - Internal Setup
    
    internal func setup() async {
        let productIds = productConfigs.map { $0.id }
        
        // Register features
        for config in productConfigs {
            for feature in config.features {
                InAppKit.shared.registerFeature(feature, productIds: [config.id])
            }
        }
        
        // Load products
        await InAppKit.shared.loadProducts(productIds: productIds)
        InAppKit.shared.isInitialized = true
    }
}

// MARK: - Environment Keys

private struct PaywallBuilderKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue: ((PaywallContext) -> AnyView)? = nil
}

private struct TermsBuilderKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue: (() -> AnyView)? = nil
}

private struct PrivacyBuilderKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue: (() -> AnyView)? = nil
}

public extension EnvironmentValues {
    var paywallBuilder: ((PaywallContext) -> AnyView)? {
        get { self[PaywallBuilderKey.self] }
        set { self[PaywallBuilderKey.self] = newValue }
    }
    
    var termsBuilder: (() -> AnyView)? {
        get { self[TermsBuilderKey.self] }
        set { self[TermsBuilderKey.self] = newValue }
    }
    
    var privacyBuilder: (() -> AnyView)? {
        get { self[PrivacyBuilderKey.self] }
        set { self[PrivacyBuilderKey.self] = newValue }
    }
}

// MARK: - Chainable View Wrapper

@MainActor
public struct ChainableStoreKitView<Content: View>: View {
    let content: Content
    let config: StoreKitConfiguration
    
    internal init(content: Content, config: StoreKitConfiguration) {
        self.content = content
        self.config = config
    }
    
    public var body: some View {
        content.modifier(InAppKitModifier(config: config))
    }
    
    /// Add paywall configuration to the chain
    public func withPaywall<PaywallContent: View>(@ViewBuilder _ builder: @escaping (PaywallContext) -> PaywallContent) -> ChainableStoreKitView<Content> {
        let newConfig = config.withPaywall(builder)
        return ChainableStoreKitView(content: content, config: newConfig)
    }
    
    /// Add terms configuration to the chain
    public func withTerms<TermsContent: View>(@ViewBuilder _ builder: @escaping () -> TermsContent) -> ChainableStoreKitView<Content> {
        let newConfig = config.withTerms(builder)
        return ChainableStoreKitView(content: content, config: newConfig)
    }
    
    /// Add privacy configuration to the chain
    public func withPrivacy<PrivacyContent: View>(@ViewBuilder _ builder: @escaping () -> PrivacyContent) -> ChainableStoreKitView<Content> {
        let newConfig = config.withPrivacy(builder)
        return ChainableStoreKitView(content: content, config: newConfig)
    }
}

// MARK: - InAppKit Modifier

private struct InAppKitModifier: ViewModifier {
    let config: StoreKitConfiguration
    
    func body(content: Content) -> some View {
        content
            .environment(\.paywallBuilder, config.paywallBuilder)
            .environment(\.termsBuilder, config.termsBuilder)
            .environment(\.privacyBuilder, config.privacyBuilder)
            .task {
                await config.setup()
            }
    }
}

// MARK: - Chainable View Extensions

public extension View {
    /// Start fluent API chain with products
    func withPurchases<T: Hashable & Sendable>(products: [ProductConfig<T>]) -> ChainableStoreKitView<Self> {
        let config = StoreKitConfiguration()
            .withPurchases(products: products)
        return ChainableStoreKitView(content: self, config: config)
    }

    /// Start fluent API chain with simple products (no features)
    func withPurchases(products: [ProductConfig<String>]) -> ChainableStoreKitView<Self> {
        let config = StoreKitConfiguration()
            .withPurchases(products: products)
        return ChainableStoreKitView(content: self, config: config)
    }
    
    /// Start fluent API chain with single product
    func withPurchases(_ productId: String) -> ChainableStoreKitView<Self> {
        let config = StoreKitConfiguration()
            .withPurchases(productId)
        return ChainableStoreKitView(content: self, config: config)
    }

    /// Start fluent API chain with multiple product IDs (variadic)
    func withPurchases(_ productIds: String...) -> ChainableStoreKitView<Self> {
        let config = StoreKitConfiguration()
        let configs = productIds.map { InternalProductConfig(id: $0, features: []) }
        config.productConfigs.append(contentsOf: configs)
        return ChainableStoreKitView(content: self, config: config)
    }
}
