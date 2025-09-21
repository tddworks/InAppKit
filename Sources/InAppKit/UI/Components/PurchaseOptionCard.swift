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
    
    private var productDescription: String {
        switch product.type {
        case .autoRenewable:
            if let period = product.subscription?.subscriptionPeriod {
                return "\(periodDescription(period)) subscription • Auto-renewable"
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
            if let period = product.subscription?.subscriptionPeriod {
                return periodText(period)
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
                    Text(product.displayName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)

                    Text(productDescription)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(product.displayPrice)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)

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
            // Example showing different selection states
            Group {
                // Unselected Monthly Card
                PurchaseOptionCardPreview(
                    title: "Pro Monthly",
                    description: "Monthly subscription • Auto-renewable",
                    price: "$9.99",
                    billingPeriod: "Monthly",
                    isSelected: false
                )

                // Selected Annual Card
                PurchaseOptionCardPreview(
                    title: "Pro Annual",
                    description: "Annual subscription • Auto-renewable",
                    price: "$99.99",
                    billingPeriod: "Yearly",
                    isSelected: true
                )

                // Lifetime Purchase Card
                PurchaseOptionCardPreview(
                    title: "Pro Lifetime",
                    description: "One-time purchase • Lifetime access",
                    price: "$199.99",
                    billingPeriod: "Lifetime",
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
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)

                    Text(description)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(price)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)

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
