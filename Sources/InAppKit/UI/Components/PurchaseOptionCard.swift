//
//  PurchaseOptionCard.swift
//  InAppKit
//
//  Purchase option card component for paywall - displays pricing and billing info
//

import SwiftUI
import StoreKit

struct PurchaseOptionCard: View {
    let product: Product
    let isSelected: Bool
    let onSelect: () -> Void

    // Optional marketing enhancements
    let badge: String?
    let features: [String]?
    let savings: String?

    init(
        product: Product,
        isSelected: Bool,
        onSelect: @escaping () -> Void,
        badge: String? = nil,
        features: [String]? = nil,
        savings: String? = nil
    ) {
        self.product = product
        self.isSelected = isSelected
        self.onSelect = onSelect
        self.badge = badge
        self.features = features
        self.savings = savings
    }
    
    private var productDescription: String {
        switch product.type {
        case .autoRenewable:
            if let subscription = product.subscription {
                var description = ""

                // Add trial info if available
                if let intro = subscription.introductoryOffer,
                   intro.paymentMode == .freeTrial {
                    let trialLength = periodText(intro.period)
                    description += "\(trialLength) free trial • "
                }

                // Add subscription period
                let period = subscription.subscriptionPeriod
                description += "\(periodDescription(period)) subscription"

                return description
            }
            return "Subscription • Auto-renewable"
        case .nonConsumable:
            return "One-time purchase • Lifetime access"
        case .consumable:
            return "Consumable purchase"
        default:
            return "In-app purchase"
        }
    }

    private var billingPeriod: String {
        switch product.type {
        case .autoRenewable:
            if let subscription = product.subscription {
                return periodText(subscription.subscriptionPeriod)
            }
            return "Subscription"
        case .nonConsumable:
            return "Lifetime"
        case .consumable:
            return "Per use"
        default:
            return "Purchase"
        }
    }

    private func periodDescription(_ period: Product.SubscriptionPeriod) -> String {
        let unit = period.unit
        let value = period.value

        switch unit {
        case .day:
            return value == 1 ? "Daily" : "\(value)-day"
        case .week:
            return value == 1 ? "Weekly" : "\(value)-week"
        case .month:
            return value == 1 ? "Monthly" : "\(value)-month"
        case .year:
            return value == 1 ? "Annual" : "\(value)-year"
        @unknown default:
            return "Periodic"
        }
    }

    private func periodText(_ period: Product.SubscriptionPeriod) -> String {
        let unit = period.unit
        let value = period.value

        switch unit {
        case .day:
            return value == 1 ? "Daily" : "Every \(value) days"
        case .week:
            return value == 1 ? "Weekly" : "Every \(value) weeks"
        case .month:
            return value == 1 ? "Monthly" : "Every \(value) months"
        case .year:
            return value == 1 ? "Yearly" : "Every \(value) years"
        @unknown default:
            return "Periodic"
        }
    }

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                // Enhanced selection indicator
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 20, height: 20)
                        .background(
                            Circle()
                                .fill(isSelected ? Color.blue.opacity(0.1) : Color.clear)
                        )
                    
                    if isSelected {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 10, height: 10)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(product.displayName)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)

                        if let badge = badge {
                            Text(badge)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(badge.lowercased().contains("popular") ? Color.orange : Color.blue)
                                )
                        }

                        Spacer()
                    }

                    Text(productDescription)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)

                    // Show key features if provided
                    if let features = features, !features.isEmpty {
                        VStack(alignment: .leading, spacing: 2) {
                            ForEach(features.prefix(2), id: \.self) { feature in
                                HStack(spacing: 4) {
                                    Text("•")
                                        .foregroundColor(.secondary)
                                        .font(.system(size: 11))
                                    Text(feature)
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.top, 2)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(product.displayPrice)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)

                    if let savings = savings {
                        Text(savings)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.green)
                    }

                    Text(billingPeriod)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? Color.blue.opacity(0.06) : Color(NSColor.controlBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(isSelected ? Color.blue.opacity(0.4) : Color.gray.opacity(0.15), lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Purchase Option Cards") {
    VStack(spacing: 16) {
        Text("Purchase Option Cards")
            .font(.title2.bold())
            .padding(.bottom)

        VStack(spacing: 12) {
            // Example showing different selection states and features
            Group {
                // Monthly with trial
                PurchaseOptionCardPreview(
                    title: "Pro Monthly",
                    description: "7 days free trial • Monthly subscription",
                    price: "$9.99",
                    billingPeriod: "Monthly",
                    badge: nil,
                    features: ["Cloud sync", "Premium filters"],
                    savings: nil,
                    isSelected: false
                )

                // Annual with "Most Popular" badge and savings
                PurchaseOptionCardPreview(
                    title: "Pro Annual",
                    description: "Annual subscription • Auto-renewable",
                    price: "$99.99",
                    billingPeriod: "Yearly",
                    badge: "Most Popular",
                    features: ["Cloud sync", "Premium filters", "Priority support"],
                    savings: "Save 15%",
                    isSelected: true
                )

                // Lifetime Purchase
                PurchaseOptionCardPreview(
                    title: "Pro Lifetime",
                    description: "One-time purchase • Lifetime access",
                    price: "$199.99",
                    billingPeriod: "Lifetime",
                    badge: "Best Value",
                    features: ["All features included", "Lifetime updates"],
                    savings: nil,
                    isSelected: false
                )
            }
        }
    }
    .padding()
    .background(Color(NSColor.windowBackgroundColor))
}

// MARK: - Preview Helper

private struct PurchaseOptionCardPreview: View {
    let title: String
    let description: String
    let price: String
    let billingPeriod: String
    let badge: String?
    let features: [String]?
    let savings: String?
    let isSelected: Bool

    var body: some View {
        Button(action: { }) {
            HStack(spacing: 16) {
                // Selection indicator
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 20, height: 20)
                        .background(
                            Circle()
                                .fill(isSelected ? Color.blue.opacity(0.1) : Color.clear)
                        )

                    if isSelected {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 10, height: 10)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)

                        if let badge = badge {
                            Text(badge)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(badge.lowercased().contains("popular") ? Color.orange : Color.blue)
                                )
                        }

                        Spacer()
                    }

                    Text(description)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)

                    if let features = features, !features.isEmpty {
                        VStack(alignment: .leading, spacing: 2) {
                            ForEach(features.prefix(2), id: \.self) { feature in
                                HStack(spacing: 4) {
                                    Text("•")
                                        .foregroundColor(.secondary)
                                        .font(.system(size: 11))
                                    Text(feature)
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.top, 2)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(price)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)

                    if let savings = savings {
                        Text(savings)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.green)
                    }

                    Text(billingPeriod)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? Color.blue.opacity(0.06) : Color(NSColor.controlBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(isSelected ? Color.blue.opacity(0.4) : Color.gray.opacity(0.15), lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}
#endif
