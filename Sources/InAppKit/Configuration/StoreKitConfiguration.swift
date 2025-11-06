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
    internal var paywallHeaderBuilder: (() -> AnyView)?
    internal var paywallFeaturesBuilder: (() -> AnyView)?
    internal var termsBuilder: (() -> AnyView)?
    internal var privacyBuilder: (() -> AnyView)?
    internal var termsURL: URL?
    internal var privacyURL: URL?

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
    
    /// Configure purchases with features (supports mixed types)
    public func withPurchases<T: Hashable>(products: [ProductConfig<T>]) -> StoreKitConfiguration {
        productConfigs.append(contentsOf: products.map { $0.toInternal() })
        return self
    }

    /// Configure purchases with simple products (no features)
    public func withPurchases(products: [ProductConfig<String>]) -> StoreKitConfiguration {
        productConfigs.append(contentsOf: products.map { $0.toInternal() })
        return self
    }

    /// Configure purchases with mixed product types (generic protocol approach)
    public func withPurchases(products: [AnyProductConfig]) -> StoreKitConfiguration {
        productConfigs.append(contentsOf: products.map { $0.toInternal() })
        return self
    }

    /// Configure custom paywall
    public func withPaywall<Content: View>(@ViewBuilder _ builder: @escaping (PaywallContext) -> Content) -> StoreKitConfiguration {
        paywallBuilder = { context in AnyView(builder(context)) }
        return self
    }
    
    /// Configure terms view with custom SwiftUI content
    public func withTerms<Content: View>(@ViewBuilder _ builder: @escaping () -> Content) -> StoreKitConfiguration {
        termsBuilder = { AnyView(builder()) }
        return self
    }

    /// Configure terms with a URL to display
    /// - Parameter url: The URL to open when terms is tapped
    /// - Returns: The configuration instance for chaining
    public func withTerms(url: URL) -> StoreKitConfiguration {
        termsURL = url
        return self
    }

    /// Configure privacy view with custom SwiftUI content
    public func withPrivacy<Content: View>(@ViewBuilder _ builder: @escaping () -> Content) -> StoreKitConfiguration {
        privacyBuilder = { AnyView(builder()) }
        return self
    }

    /// Configure privacy with a URL to display
    /// - Parameter url: The URL to open when privacy is tapped
    /// - Returns: The configuration instance for chaining
    public func withPrivacy(url: URL) -> StoreKitConfiguration {
        privacyURL = url
        return self
    }

    /// Configure paywall header section
    public func withPaywallHeader<Content: View>(@ViewBuilder _ builder: @escaping () -> Content) -> StoreKitConfiguration {
        paywallHeaderBuilder = { AnyView(builder()) }
        return self
    }

    /// Configure paywall features section
    public func withPaywallFeatures<Content: View>(@ViewBuilder _ builder: @escaping () -> Content) -> StoreKitConfiguration {
        paywallFeaturesBuilder = { AnyView(builder()) }
        return self
    }
    
    // MARK: - Internal Setup
    
    internal func setup() async {
        // Use the existing InAppKit.initialize method which handles both features and marketing info
        await InAppKit.shared.initialize(with: productConfigs)
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

private struct PaywallHeaderBuilderKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue: (() -> AnyView)? = nil
}

private struct PaywallFeaturesBuilderKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue: (() -> AnyView)? = nil
}

private struct TermsURLKey: EnvironmentKey {
    static let defaultValue: URL? = nil
}

private struct PrivacyURLKey: EnvironmentKey {
    static let defaultValue: URL? = nil
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

    var paywallHeaderBuilder: (() -> AnyView)? {
        get { self[PaywallHeaderBuilderKey.self] }
        set { self[PaywallHeaderBuilderKey.self] = newValue }
    }

    var paywallFeaturesBuilder: (() -> AnyView)? {
        get { self[PaywallFeaturesBuilderKey.self] }
        set { self[PaywallFeaturesBuilderKey.self] = newValue }
    }

    var termsURL: URL? {
        get { self[TermsURLKey.self] }
        set { self[TermsURLKey.self] = newValue }
    }

    var privacyURL: URL? {
        get { self[PrivacyURLKey.self] }
        set { self[PrivacyURLKey.self] = newValue }
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
    
    /// Add terms configuration to the chain with custom SwiftUI content
    public func withTerms<TermsContent: View>(@ViewBuilder _ builder: @escaping () -> TermsContent) -> ChainableStoreKitView<Content> {
        let newConfig = config.withTerms(builder)
        return ChainableStoreKitView(content: content, config: newConfig)
    }

    /// Add terms configuration to the chain with a URL
    public func withTerms(url: URL) -> ChainableStoreKitView<Content> {
        let newConfig = config.withTerms(url: url)
        return ChainableStoreKitView(content: content, config: newConfig)
    }

    /// Add privacy configuration to the chain with custom SwiftUI content
    public func withPrivacy<PrivacyContent: View>(@ViewBuilder _ builder: @escaping () -> PrivacyContent) -> ChainableStoreKitView<Content> {
        let newConfig = config.withPrivacy(builder)
        return ChainableStoreKitView(content: content, config: newConfig)
    }

    /// Add privacy configuration to the chain with a URL
    public func withPrivacy(url: URL) -> ChainableStoreKitView<Content> {
        let newConfig = config.withPrivacy(url: url)
        return ChainableStoreKitView(content: content, config: newConfig)
    }

    /// Add paywall header configuration to the chain
    public func withPaywallHeader<HeaderContent: View>(@ViewBuilder _ builder: @escaping () -> HeaderContent) -> ChainableStoreKitView<Content> {
        let newConfig = config.withPaywallHeader(builder)
        return ChainableStoreKitView(content: content, config: newConfig)
    }

    /// Add paywall features configuration to the chain
    public func withPaywallFeatures<FeaturesContent: View>(@ViewBuilder _ builder: @escaping () -> FeaturesContent) -> ChainableStoreKitView<Content> {
        let newConfig = config.withPaywallFeatures(builder)
        return ChainableStoreKitView(content: content, config: newConfig)
    }
}

// MARK: - InAppKit Modifier

private struct InAppKitModifier: ViewModifier {
    let config: StoreKitConfiguration

    func body(content: Content) -> some View {
        content
            .environment(\.paywallBuilder, config.paywallBuilder)
            .environment(\.paywallHeaderBuilder, config.paywallHeaderBuilder)
            .environment(\.paywallFeaturesBuilder, config.paywallFeaturesBuilder)
            .environment(\.termsBuilder, config.termsBuilder)
            .environment(\.privacyBuilder, config.privacyBuilder)
            .environment(\.termsURL, config.termsURL)
            .environment(\.privacyURL, config.privacyURL)
            .task {
                await config.setup()
            }
    }
}

// MARK: - Chainable View Extensions

public extension View {
    /// Start fluent API chain with products
    func withPurchases<T: Hashable>(products: [ProductConfig<T>]) -> ChainableStoreKitView<Self> {
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

    /// Start fluent API chain with mixed product types
    func withPurchases(products: [AnyProductConfig]) -> ChainableStoreKitView<Self> {
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
