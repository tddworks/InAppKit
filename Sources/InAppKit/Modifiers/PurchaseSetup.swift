//
//  PurchaseSetup.swift
//  InAppKit
//
//  SwiftUI integration for setting up purchases.
//  "I'm setting up my app to handle purchases"
//

import Foundation
import SwiftUI
import StoreKit

// MARK: - Purchase Setup Builder

/// Builder for configuring purchases in your app.
/// Internal implementation - users interact via .withPurchases() modifier.
@MainActor
public class PurchaseSetup {
    internal var productConfigs: [InternalProductConfig] = []
    internal var paywallBuilder: ((PaywallContext) -> AnyView)?
    internal var paywallHeaderBuilder: (() -> AnyView)?
    internal var paywallFeaturesBuilder: (() -> AnyView)?
    internal var termsBuilder: (() -> AnyView)?
    internal var privacyBuilder: (() -> AnyView)?
    internal var termsURL: URL?
    internal var privacyURL: URL?

    public init() {}

    // MARK: - Product Configuration

    public func withPurchases(_ productId: String) -> PurchaseSetup {
        productConfigs.append(InternalProductConfig(id: productId, features: []))
        return self
    }

    public func withPurchases(_ productIds: String...) -> PurchaseSetup {
        productConfigs.append(contentsOf: productIds.map { InternalProductConfig(id: $0, features: []) })
        return self
    }

    public func withPurchases<T: Hashable>(products: [ProductDefinition<T>]) -> PurchaseSetup {
        productConfigs.append(contentsOf: products.map { $0.toInternal() })
        return self
    }

    public func withPurchases(products: [ProductDefinition<String>]) -> PurchaseSetup {
        productConfigs.append(contentsOf: products.map { $0.toInternal() })
        return self
    }

    public func withPurchases(products: [AnyProductDefinition]) -> PurchaseSetup {
        productConfigs.append(contentsOf: products.map { $0.toInternal() })
        return self
    }

    // MARK: - Paywall Configuration

    public func withPaywall<Content: View>(@ViewBuilder _ builder: @escaping (PaywallContext) -> Content) -> PurchaseSetup {
        paywallBuilder = { context in AnyView(builder(context)) }
        return self
    }

    public func withPaywallHeader<Content: View>(@ViewBuilder _ builder: @escaping () -> Content) -> PurchaseSetup {
        paywallHeaderBuilder = { AnyView(builder()) }
        return self
    }

    public func withPaywallFeatures<Content: View>(@ViewBuilder _ builder: @escaping () -> Content) -> PurchaseSetup {
        paywallFeaturesBuilder = { AnyView(builder()) }
        return self
    }

    // MARK: - Legal Configuration

    public func withTerms<Content: View>(@ViewBuilder _ builder: @escaping () -> Content) -> PurchaseSetup {
        termsBuilder = { AnyView(builder()) }
        return self
    }

    public func withTerms(url: URL) -> PurchaseSetup {
        termsURL = url
        return self
    }

    public func withPrivacy<Content: View>(@ViewBuilder _ builder: @escaping () -> Content) -> PurchaseSetup {
        privacyBuilder = { AnyView(builder()) }
        return self
    }

    public func withPrivacy(url: URL) -> PurchaseSetup {
        privacyURL = url
        return self
    }

    // MARK: - Internal

    internal func setup() async {
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

// MARK: - Purchase Enabled View

/// A view with purchases enabled.
/// Internal wrapper - users don't see this directly.
@MainActor
public struct PurchaseEnabledView<Content: View>: View {
    let content: Content
    let config: PurchaseSetup

    internal init(content: Content, config: PurchaseSetup) {
        self.content = content
        self.config = config
    }

    public var body: some View {
        content.modifier(PurchaseSetupModifier(config: config))
    }

    public func withPaywall<PaywallContent: View>(@ViewBuilder _ builder: @escaping (PaywallContext) -> PaywallContent) -> PurchaseEnabledView<Content> {
        PurchaseEnabledView(content: content, config: config.withPaywall(builder))
    }

    public func withTerms<TermsContent: View>(@ViewBuilder _ builder: @escaping () -> TermsContent) -> PurchaseEnabledView<Content> {
        PurchaseEnabledView(content: content, config: config.withTerms(builder))
    }

    public func withTerms(url: URL) -> PurchaseEnabledView<Content> {
        PurchaseEnabledView(content: content, config: config.withTerms(url: url))
    }

    public func withPrivacy<PrivacyContent: View>(@ViewBuilder _ builder: @escaping () -> PrivacyContent) -> PurchaseEnabledView<Content> {
        PurchaseEnabledView(content: content, config: config.withPrivacy(builder))
    }

    public func withPrivacy(url: URL) -> PurchaseEnabledView<Content> {
        PurchaseEnabledView(content: content, config: config.withPrivacy(url: url))
    }

    public func withPaywallHeader<HeaderContent: View>(@ViewBuilder _ builder: @escaping () -> HeaderContent) -> PurchaseEnabledView<Content> {
        PurchaseEnabledView(content: content, config: config.withPaywallHeader(builder))
    }

    public func withPaywallFeatures<FeaturesContent: View>(@ViewBuilder _ builder: @escaping () -> FeaturesContent) -> PurchaseEnabledView<Content> {
        PurchaseEnabledView(content: content, config: config.withPaywallFeatures(builder))
    }
}

// MARK: - Purchase Setup Modifier

private struct PurchaseSetupModifier: ViewModifier {
    let config: PurchaseSetup

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

// MARK: - View Extensions

public extension View {
    /// Set up purchases with products
    func withPurchases<T: Hashable>(products: [ProductDefinition<T>]) -> PurchaseEnabledView<Self> {
        PurchaseEnabledView(content: self, config: PurchaseSetup().withPurchases(products: products))
    }

    func withPurchases(products: [ProductDefinition<String>]) -> PurchaseEnabledView<Self> {
        PurchaseEnabledView(content: self, config: PurchaseSetup().withPurchases(products: products))
    }

    func withPurchases(products: [AnyProductDefinition]) -> PurchaseEnabledView<Self> {
        PurchaseEnabledView(content: self, config: PurchaseSetup().withPurchases(products: products))
    }

    func withPurchases(_ productId: String) -> PurchaseEnabledView<Self> {
        PurchaseEnabledView(content: self, config: PurchaseSetup().withPurchases(productId))
    }

    func withPurchases(_ productIds: String...) -> PurchaseEnabledView<Self> {
        let config = PurchaseSetup()
        config.productConfigs.append(contentsOf: productIds.map { InternalProductConfig(id: $0, features: []) })
        return PurchaseEnabledView(content: self, config: config)
    }
}
