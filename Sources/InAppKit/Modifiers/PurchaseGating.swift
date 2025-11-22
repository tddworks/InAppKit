//
//  PurchaseGating.swift
//  InAppKit
//
//  Purchase gating modifiers for conditional access control
//

import SwiftUI

// MARK: - Purchase Gate Modifiers

struct PurchaseGateModifier: ViewModifier {
    let condition: () -> Bool
    @Environment(\.paywallBuilder) private var paywallBuilder
    @State private var showUpgrade = false
    
    func body(content: Content) -> some View {
        if condition() && !InAppKit.shared.hasAnyPurchase {
            content
                .disabled(true)
                .opacity(0.6)
                .overlay(PurchaseRequiredBadge(), alignment: .topTrailing)
                .onTapGesture {
                    showUpgrade = true
                }
                .platformSheet(isPresented: $showUpgrade) {
                    if let customPaywall = paywallBuilder {
                        let context = PaywallContext(
                            triggeredBy: "usage_condition",
                            availableProducts: InAppKit.shared.availableProducts
                        )
                        AutoPaywallWrapper {
                            customPaywall(context)
                        }
                    } else {
                        PaywallView()
                    }
                }
        } else {
            content
        }
    }
}

struct FeaturePurchaseGateModifier<T: Hashable>: ViewModifier {
    let feature: T
    let condition: () -> Bool
    @Environment(\.paywallBuilder) private var paywallBuilder
    @State private var showUpgrade = false
    
    func body(content: Content) -> some View {
        if condition() && !InAppKit.shared.hasAccess(to: feature) {
            content
                .disabled(true)
                .opacity(0.6)
                .overlay(PurchaseRequiredBadge(), alignment: .topTrailing)
                .onTapGesture {
                    showUpgrade = true
                }
                .sheet(isPresented: $showUpgrade) {
                    if let customPaywall = paywallBuilder {
                        let context = PaywallContext(
                            triggeredBy: String(describing: feature),
                            availableProducts: InAppKit.shared.availableProducts
                        )
                        AutoPaywallWrapper {
                            customPaywall(context)
                        }
                    } else {
                        PaywallView()
                    }
                }
        } else {
            content
        }
    }
}

// MARK: - Convenience Extensions for Common Usage Patterns

public extension Int {
    var mb: Int { self * 1024 * 1024 }
    var MB: Int { mb }
}
