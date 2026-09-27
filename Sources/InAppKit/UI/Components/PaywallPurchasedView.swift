//
//  PaywallPurchasedView.swift
//  InAppKit
//
//  Default content shown in the paywall once the user already owns a product
//

import SwiftUI
import StoreKit

/// Shown in place of product cards and the purchase button when the user already has access.
/// Enable with `.withPaywallPurchased()`, or pass your own view to `.withPaywallPurchased { ... }`.
public struct PaywallPurchasedView: View {
    @State private var inAppKit = InAppKit.shared
    @State private var showManageSubscriptions = false

    private let title: String
    private let subtitle: String

    public init(
        title: String = "paywall.purchased.title".localized(fallback: "You're all set"),
        subtitle: String = "paywall.purchased.subtitle".localized(fallback: "All premium features are unlocked.")
    ) {
        self.title = title
        self.subtitle = subtitle
    }

    /// Names of owned products that are still offered, e.g. "Lifetime Pass".
    private var ownedProductNames: [String] {
        inAppKit.availableProducts
            .filter { inAppKit.isPurchased($0.id) }
            .map(\.displayName)
    }

    private var hasActiveSubscription: Bool {
        inAppKit.availableProducts.contains { $0.type == .autoRenewable && inAppKit.isPurchased($0.id) }
    }

    public var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 44, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(colors: [.green, .mint], startPoint: .topLeading, endPoint: .bottomTrailing)
                )

            VStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                Text(subtitle)
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            if !ownedProductNames.isEmpty {
                Text(ownedProductNames.joined(separator: " · "))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.green)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.green.opacity(0.12))
                    .clipShape(Capsule())
            }

            #if os(iOS)
            if hasActiveSubscription {
                Button("paywall.purchased.manage".localized(fallback: "Manage Subscription")) {
                    showManageSubscriptions = true
                }
                .font(.system(size: 15, weight: .medium))
                .platformButtonStyle()
                .manageSubscriptionsSheet(isPresented: $showManageSubscriptions)
            }
            #endif
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.green.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.green.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    PaywallPurchasedView()
        .padding()
}
