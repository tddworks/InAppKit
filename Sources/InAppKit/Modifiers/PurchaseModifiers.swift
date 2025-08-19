//
//  PurchaseModifiers.swift
//  InAppKit
//
//  Modern .requiresPurchase() view modifiers for type-safe purchase requirements
//

import SwiftUI
import StoreKit
import OSLog

// MARK: - New Fluent API Extensions

public extension View {
    // MARK: - .requiresPurchase() API
    
    /// Universal purchase requirement - any purchase
    func requiresPurchase() -> some View {
        self.modifier(UniversalPurchaseModifier(requirement: nil, condition: true))
    }
    
    /// Specific product requirement
    func requiresPurchase(_ productId: String) -> some View {
        self.modifier(ProductPurchaseModifier(productId: productId, condition: true))
    }
    
    /// Feature-based requirement
    func requiresPurchase<T: Hashable>(_ feature: T) -> some View {
        self.modifier(UniversalPurchaseModifier(requirement: feature, condition: true))
    }
    
    /// Conditional purchase requirement - any purchase
    func requiresPurchase(when condition: Bool) -> some View {
        self.modifier(UniversalPurchaseModifier(requirement: nil, condition: condition))
    }
    
    /// Conditional product requirement
    func requiresPurchase(_ productId: String, when condition: Bool) -> some View {
        self.modifier(ProductPurchaseModifier(productId: productId, condition: condition))
    }
    
    /// Conditional feature requirement
    func requiresPurchase<T: Hashable>(_ feature: T, when condition: Bool) -> some View {
        self.modifier(UniversalPurchaseModifier(requirement: feature, condition: condition))
    }
    
    /// Usage-based gating with closure
    func requiresPurchase(when condition: @escaping () -> Bool) -> some View {
        self.modifier(PurchaseGateModifier(condition: condition))
    }
    
    /// Feature + condition gating
    func requiresPurchase<T: Hashable>(_ feature: T, when condition: @escaping () -> Bool) -> some View {
        self.modifier(FeaturePurchaseGateModifier(feature: feature, condition: condition))
    }
    
    /// Usage-based gating with item count
    func requiresPurchase(whenItemCount count: Int, exceeds limit: Int) -> some View {
        requiresPurchase(when: count > limit)
    }
    
    /// File size based gating
    func requiresPurchase<T: Hashable>(_ feature: T, whenFileSize size: Int, exceeds limit: Int) -> some View {
        requiresPurchase(feature, when: { size > limit })
    }
}

// MARK: - Universal Purchase Modifier

public struct UniversalPurchaseModifier: ViewModifier {
    let requirement: Any?
    let condition: Bool
    @Environment(\.paywallBuilder) private var paywallBuilder
    @State private var showUpgrade = false
    
    public init(requirement: Any?, condition: Bool) {
        self.requirement = requirement
        self.condition = condition
    }
    
    public func body(content: Content) -> some View {
        if condition && !hasAccess() {
            content
                .disabled(true)
                .opacity(0.6)
                .overlay(PurchaseRequiredBadge(), alignment: .topTrailing)
                .onTapGesture {
                    showUpgrade = true
                }
                .sheet(isPresented: $showUpgrade) {
                    showPaywall()
                }
        } else {
            content
        }
    }
    
    private func hasAccess() -> Bool {
        if let requirement = requirement {
            // Check if requirement is already hashable
            if let hashableRequirement = requirement as? AnyHashable {
                // Validate feature is registered
                if !InAppKit.shared.isFeatureRegistered(hashableRequirement) {
                    #if DEBUG
                    Logger.statistics.warning("StoreKit Warning: Feature '\(String(describing: requirement))' not registered. Add Feature(\"\(String(describing: requirement))\", product: \"...\") to your storeKit configuration.")
                    // In debug, fail closed for unregistered features to catch configuration errors
                    return false
                    #else
                    // In release, fall back to any purchase check to avoid breaking user experience
                    return InAppKit.shared.hasAnyPurchase
                    #endif
                }
                
                // Feature-based check
                return InAppKit.shared.hasAccess(to: hashableRequirement)
            } else {
                // If not hashable, fall back to any purchase check
                return InAppKit.shared.hasAnyPurchase
            }
        }
        // Simple any purchase check
        return InAppKit.shared.hasAnyPurchase
    }
    
    @ViewBuilder
    private func showPaywall() -> some View {
        if let customPaywall = paywallBuilder {
            let context = PaywallContext(
                triggeredBy: requirement.map(String.init(describing:)),
                availableProducts: InAppKit.shared.availableProducts
            )
            AutoPaywallWrapper {
                customPaywall(context)
            }
        } else {
            PaywallView()
        }
    }
}

// MARK: - Product Purchase Modifier

public struct ProductPurchaseModifier: ViewModifier {
    let productId: String
    let condition: Bool
    @Environment(\.paywallBuilder) private var paywallBuilder
    @State private var showUpgrade = false
    
    public init(productId: String, condition: Bool) {
        self.productId = productId
        self.condition = condition
    }
    
    public func body(content: Content) -> some View {
        if condition && !InAppKit.shared.isPurchased(productId) {
            content
                .disabled(true)
                .opacity(0.6)
                .overlay(PurchaseRequiredBadge(), alignment: .topTrailing)
                .onTapGesture {
                    showUpgrade = true
                }
                .sheet(isPresented: $showUpgrade) {
                    showPaywall()
                }
        } else {
            content
        }
    }
    
    @ViewBuilder
    private func showPaywall() -> some View {
        if let customPaywall = paywallBuilder {
            let products = InAppKit.shared.availableProducts.filter { $0.id == productId }
            let context = PaywallContext(
                triggeredBy: "product_\(productId)",
                availableProducts: products
            )
            AutoPaywallWrapper {
                customPaywall(context)
            }
        } else {
            PaywallView()
        }
    }
}
