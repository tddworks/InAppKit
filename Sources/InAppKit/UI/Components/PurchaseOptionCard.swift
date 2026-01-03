//
//  PurchaseOptionCard.swift
//  InAppKit
//
//  Purchase option card component for paywall - displays pricing and billing info
//

import Foundation
import SwiftUI
import StoreKit
import OSLog

// MARK: - Styling Constants

private enum CardStyle {
    static let cornerRadius: CGFloat = 14
    static let horizontalPadding: CGFloat = 20
    static let verticalPadding: CGFloat = 16
    static let contentSpacing: CGFloat = 16
    static let contentVerticalSpacing: CGFloat = 4
    static let featuresSpacing: CGFloat = 2
    static let featuresTopPadding: CGFloat = 2

    static let selectionIndicatorSize: CGFloat = 20
    static let selectionIndicatorFillSize: CGFloat = 10
    static let selectionIndicatorStroke: CGFloat = 2
    static let selectedStrokeWidth: CGFloat = 2
    static let unselectedStrokeWidth: CGFloat = 1

    static let selectedScale: CGFloat = 1.02
    static let animationDuration: Double = 0.15

    // Font sizes
    static let titleFontSize: CGFloat = 16
    static let descriptionFontSize: CGFloat = 13
    static let priceFontSize: CGFloat = 18
    static let billingPeriodFontSize: CGFloat = 12
    static let badgeFontSize: CGFloat = 10
    static let promoTextFontSize: CGFloat = 10
    static let featureFontSize: CGFloat = 11

    // Badge styling
    static let badgeHorizontalPadding: CGFloat = 8
    static let badgeVerticalPadding: CGFloat = 2
}

public struct PurchaseOptionCard: View {
    let product: Product
    let isSelected: Bool
    let onSelect: () -> Void

    // Optional marketing enhancements
    let badge: String?
    let badgeColor: Color?
    let features: [String]?
    let promoText: String?

    @MainActor
    public init(
        product: Product,
        isSelected: Bool,
        onSelect: @escaping () -> Void,
        badge: String? = nil,
        badgeColor: Color? = nil,
        features: [String]? = nil,
        promoText: String? = nil
    ) {
        self.product = product
        self.isSelected = isSelected
        self.onSelect = onSelect
        self.badge = badge
        self.badgeColor = badgeColor
        self.features = features
        self.promoText = promoText
    }

    /// Computed promo text - uses manual promoText if provided, otherwise calculates from discountRule
    @MainActor
    private var displayPromoText: String? {
        // Manual promo text takes priority
        if let manualPromo = promoText {
            return manualPromo
        }

        // Calculate from discount rule
        guard let discountRule = InAppKit.shared.discountRule(for: product.id) else {
            return nil
        }

        return calculateRelativeDiscount(rule: discountRule)
    }

    /// Computed promo color - from discountRule or default orange
    @MainActor
    private var displayPromoColor: Color {
        // Get color from discount rule
        if let discountRule = InAppKit.shared.discountRule(for: product.id),
           let customColor = discountRule.color {
            return customColor
        }
        // Default to orange
        return .orange
    }

    /// Calculate the discount string based on comparison product
    @MainActor
    private func calculateRelativeDiscount(rule: DiscountRule) -> String? {
        // Find the base product to compare against
        guard let baseProduct = InAppKit.shared.availableProducts.first(where: { $0.id == rule.comparedTo }) else {
            return nil
        }

        // Get subscription periods for both products
        guard let currentSubscription = product.subscription,
              let baseSubscription = baseProduct.subscription else {
            return nil
        }

        // Calculate prices normalized to the same period
        let currentPrice = product.price
        let basePrice = baseProduct.price

        let currentPeriod = currentSubscription.subscriptionPeriod
        let basePeriod = baseSubscription.subscriptionPeriod

        // Convert both to monthly equivalent for comparison
        let currentMonthlyPrice = normalizeToMonthly(price: currentPrice, period: currentPeriod)
        let baseMonthlyPrice = normalizeToMonthly(price: basePrice, period: basePeriod)

        // Calculate savings
        let savingsAmount = baseMonthlyPrice - currentMonthlyPrice
        guard savingsAmount > 0 else { return nil }

        // Calculate based on actual billing period
        let actualSavings = calculateActualSavings(
            currentPrice: currentPrice,
            basePrice: basePrice,
            currentPeriod: currentPeriod,
            basePeriod: basePeriod
        )

        switch rule.style {
        case .percentage:
            let multiplier = NSDecimalNumber(integerLiteral: periodMultiplier(currentPeriod, comparedTo: basePeriod))
            let basePriceNumber = basePrice as NSDecimalNumber
            let actualSavingsNumber = actualSavings as NSDecimalNumber
            let totalBase = basePriceNumber.multiplying(by: multiplier)
            let percentageDecimal = actualSavingsNumber.dividing(by: totalBase).multiplying(by: NSDecimalNumber(integerLiteral: 100))
            let percentage = Int(percentageDecimal.doubleValue.rounded())
            return "discount.percentage".localized("\(percentage)", fallback: "Save \(percentage)%%")

        case .amount:
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = product.priceFormatStyle.locale
            if let formattedAmount = formatter.string(from: actualSavings as NSDecimalNumber) {
                return "discount.amount".localized(formattedAmount, fallback: "Save \(formattedAmount)")
            }
            return nil

        case .freeTime:
            // Calculate how many free periods you get
            let actualSavingsNumber = actualSavings as NSDecimalNumber
            let baseMonthlyNumber = baseMonthlyPrice as NSDecimalNumber
            let freeMonthsDecimal = actualSavingsNumber.dividing(by: baseMonthlyNumber)
            let freeMonths = Int(freeMonthsDecimal.doubleValue)
            if freeMonths > 0 {
                return "discount.free_time".localized("\(freeMonths)", fallback: "\(freeMonths) months free")
            }
            return nil
        }
    }

    /// Normalize a price to monthly equivalent
    private func normalizeToMonthly(price: Decimal, period: Product.SubscriptionPeriod) -> Decimal {
        let monthsInPeriod = monthsInSubscriptionPeriod(period)
        return price / Decimal(monthsInPeriod)
    }

    /// Calculate the actual savings for the billing period
    private func calculateActualSavings(currentPrice: Decimal, basePrice: Decimal, currentPeriod: Product.SubscriptionPeriod, basePeriod: Product.SubscriptionPeriod) -> Decimal {
        let baseMonthly = normalizeToMonthly(price: basePrice, period: basePeriod)
        let monthsInCurrent = monthsInSubscriptionPeriod(currentPeriod)
        return (baseMonthly * Decimal(monthsInCurrent)) - currentPrice
    }

    /// Get the multiplier between two periods
    private func periodMultiplier(_ period: Product.SubscriptionPeriod, comparedTo base: Product.SubscriptionPeriod) -> Int {
        return monthsInSubscriptionPeriod(period) / monthsInSubscriptionPeriod(base)
    }

    /// Convert subscription period to months
    private func monthsInSubscriptionPeriod(_ period: Product.SubscriptionPeriod) -> Int {
        let value = period.value
        switch period.unit {
        case .day:
            return max(1, value / 30) // Approximate
        case .week:
            return max(1, value / 4) // Approximate (4 weeks = 1 month)
        case .month:
            return value
        case .year:
            return value * 12
        @unknown default:
            return value
        }
    }
    
    private var productDescription: String {
        // Use user-defined description from StoreKit if available
        if !product.description.isEmpty && product.description != product.displayName {
            return product.description
        }

        // Fallback to auto-generated description (without intro offer info)
        return autoGeneratedDescription
    }

    private var autoGeneratedDescription: String {
        switch product.type {
        case .autoRenewable:
            if let subscription = product.subscription {
                // Just show subscription period (intro offers shown separately)
                let period = subscription.subscriptionPeriod
                return "\(periodText(period, style: .billing)) subscription"
            }
            return "purchase.subscription.description".localized(fallback: "Subscription • Auto-renewable")
        case .nonConsumable:
            return "purchase.lifetime.description".localized(fallback: "One-time purchase • Lifetime access")
        case .consumable:
            return "purchase.consumable.description".localized(fallback: "Consumable purchase")
        default:
            return "purchase.unknown.description".localized(fallback: "In-app purchase")
        }
    }

    private var introductoryOfferDescription: String? {
        guard let subscription = product.subscription,
              let intro = subscription.introductoryOffer else {
            return nil
        }

        let period = periodText(intro.period, style: .descriptive)
        let periodCount = intro.periodCount

        switch intro.paymentMode {
        case .freeTrial:
            // e.g., "7 days free trial"
            let duration = durationText(intro.period)
            return "purchase.intro.free_trial".localized("\(duration)", fallback: "\(duration) free trial")
        case .payAsYouGo:
            // e.g., "$0.99 for first 3 months" or "$0.99/month for 3 months"
            if periodCount > 1 {
                return "purchase.intro.pay_as_you_go_multiple".localized("\(intro.displayPrice)", "\(periodCount)", "\(period)", fallback: "\(intro.displayPrice) for \(periodCount) \(period)s")
            } else {
                return "purchase.intro.pay_as_you_go_single".localized("\(intro.displayPrice)", "\(period)", fallback: "\(intro.displayPrice) for first \(period)")
            }
        case .payUpFront:
            // e.g., "$2.99 for first month"
            if periodCount > 1 {
                return "purchase.intro.pay_upfront_multiple".localized("\(intro.displayPrice)", "\(periodCount)", "\(period)", fallback: "\(intro.displayPrice) for first \(periodCount) \(period)s")
            } else {
                return "purchase.intro.pay_upfront_single".localized("\(intro.displayPrice)", "\(period)", fallback: "\(intro.displayPrice) for first \(period)")
            }
        default:
            return nil
        }
    }

    /// Formats a subscription period as a duration (e.g., "7 days", "1 month", "3 months")
    private func durationText(_ period: Product.SubscriptionPeriod) -> String {
        let unit = period.unit
        let value = period.value

        switch unit {
        case .day:
            return value == 1
                ? "purchase.duration.day_single".localized(fallback: "1 day")
                : "purchase.duration.day_multiple".localized("\(value)", fallback: "\(value) days")
        case .week:
            return value == 1
                ? "purchase.duration.week_single".localized(fallback: "1 week")
                : "purchase.duration.week_multiple".localized("\(value)", fallback: "\(value) weeks")
        case .month:
            return value == 1
                ? "purchase.duration.month_single".localized(fallback: "1 month")
                : "purchase.duration.month_multiple".localized("\(value)", fallback: "\(value) months")
        case .year:
            return value == 1
                ? "purchase.duration.year_single".localized(fallback: "1 year")
                : "purchase.duration.year_multiple".localized("\(value)", fallback: "\(value) years")
        @unknown default:
            return "purchase.duration.unknown".localized(fallback: "\(value) periods")
        }
    }

    private var billingPeriod: String {
        switch product.type {
        case .autoRenewable:
            if let subscription = product.subscription {
                return periodText(subscription.subscriptionPeriod, style: .billing)
            }
            return "purchase.subscription.type".localized(fallback: "Subscription")
        case .nonConsumable:
            return "purchase.lifetime.type".localized(fallback: "Lifetime")
        case .consumable:
            return "purchase.consumable.type".localized(fallback: "Per use")
        default:
            return "purchase.unknown.type".localized(fallback: "Purchase")
        }
    }

    private func periodText(_ period: Product.SubscriptionPeriod, style: PeriodTextStyle = .billing) -> String {
        let unit = period.unit
        let value = period.value

        switch style {
        case .billing:
            switch unit {
            case .day:
                return value == 1
                    ? "purchase.period.billing.daily".localized(fallback: "Daily")
                    : "purchase.period.billing.day_multiple".localized("\(value)", fallback: "\(value)-day")
            case .week:
                return value == 1
                    ? "purchase.period.billing.weekly".localized(fallback: "Weekly")
                    : "purchase.period.billing.week_multiple".localized("\(value)", fallback: "\(value)-week")
            case .month:
                return value == 1
                    ? "purchase.period.billing.monthly".localized(fallback: "Monthly")
                    : "purchase.period.billing.month_multiple".localized("\(value)", fallback: "\(value)-month")
            case .year:
                return value == 1
                    ? "purchase.period.billing.annual".localized(fallback: "Annual")
                    : "purchase.period.billing.year_multiple".localized("\(value)", fallback: "\(value)-year")
            @unknown default:
                return "purchase.period.billing.periodic".localized(fallback: "Periodic")
            }
        case .descriptive:
            switch unit {
            case .day:
                return value == 1
                    ? "purchase.period.descriptive.daily".localized(fallback: "Daily")
                    : "purchase.period.descriptive.day_multiple".localized("\(value)", fallback: "Every \(value) days")
            case .week:
                return value == 1
                    ? "purchase.period.descriptive.weekly".localized(fallback: "Weekly")
                    : "purchase.period.descriptive.week_multiple".localized("\(value)", fallback: "Every \(value) weeks")
            case .month:
                return value == 1
                    ? "purchase.period.descriptive.monthly".localized(fallback: "Monthly")
                    : "purchase.period.descriptive.month_multiple".localized("\(value)", fallback: "Every \(value) months")
            case .year:
                return value == 1
                    ? "purchase.period.descriptive.yearly".localized(fallback: "Yearly")
                    : "purchase.period.descriptive.year_multiple".localized("\(value)", fallback: "Every \(value) years")
            @unknown default:
                return "purchase.period.descriptive.periodic".localized(fallback: "Periodic")
            }
        }
    }

    private enum PeriodTextStyle {
        case billing     // "Monthly", "Annual"
        case descriptive // "Every month", "Every year"
    }

    private var productIconType: ProductIconType {
        switch product.type {
        case .nonConsumable:
            return .lifetime
        case .autoRenewable:
            if let subscription = product.subscription {
                switch subscription.subscriptionPeriod.unit {
                case .day:
                    return .daily
                case .week:
                    return .weekly
                case .month:
                    return .monthly
                case .year:
                    return .yearly
                @unknown default:
                    return .subscription
                }
            }
            return .subscription
        default:
            return .other
        }
    }

    public var body: some View {
        PurchaseOptionCardView(
            title: product.displayName,
            price: product.displayPrice,
            billingPeriod: billingPeriod,
            badge: badge,
            badgeColor: badgeColor,
            features: features,
            promoText: displayPromoText,
            promoColor: displayPromoColor,
            introductoryOffer: introductoryOfferDescription,
            description: productDescription,
            productIconType: productIconType,
            isSelected: isSelected,
            onSelect: onSelect
        )
    }
}

// MARK: - Product Icon Type

private enum ProductIconType {
    case daily
    case weekly
    case monthly
    case yearly
    case lifetime
    case subscription
    case other
}

// MARK: - Shared UI Component

private struct PurchaseOptionCardView: View {
    let title: String
    let price: String
    let billingPeriod: String
    let badge: String?
    let badgeColor: Color?
    let features: [String]?
    let promoText: String?
    let promoColor: Color
    let introductoryOffer: String?
    let description: String?
    let productIconType: ProductIconType
    let isSelected: Bool
    let onSelect: () -> Void

    // MARK: - Subviews

    private var selectionIndicator: some View {
        ZStack {
            Circle()
                .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: CardStyle.selectionIndicatorStroke)
                .frame(width: CardStyle.selectionIndicatorSize, height: CardStyle.selectionIndicatorSize)

            if isSelected {
                Circle()
                    .fill(Color.blue)
                    .frame(width: CardStyle.selectionIndicatorFillSize, height: CardStyle.selectionIndicatorFillSize)
            }
        }
        .padding(.top, 2)
    }

    @ViewBuilder
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
                .lineLimit(1)
                .truncationMode(.tail)

            // Introductory offer badge
            if let introOffer = introductoryOffer {
                introOfferBadge(introOffer)
            } else if description != nil {
                productIcon
            }

            // Promo text display
            if let displayText = promoText {
                promoLabel(displayText)
            }
        }
    }

    private func introOfferBadge(_ text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "gift.fill")
                .font(.system(size: 9))
                .foregroundColor(.green)
            Text(text)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.green)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.green.opacity(0.15))
        )
    }

    @ViewBuilder
    private var productIcon: some View {
        switch productIconType {
        case .daily:
            subscriptionIcon(systemName: "sun.max.fill", colors: [.orange, .yellow])
        case .weekly:
            subscriptionIcon(systemName: "calendar.badge.clock", colors: [.blue, .cyan])
        case .monthly:
            subscriptionIcon(systemName: "calendar", colors: [.purple, .indigo])
        case .yearly:
            subscriptionIcon(systemName: "calendar.badge.checkmark", colors: [.green, .mint])
        case .lifetime:
            subscriptionIcon(systemName: "infinity", colors: [.yellow, .orange])
        case .subscription:
            subscriptionIcon(systemName: "arrow.triangle.2.circlepath", colors: [.blue, .purple])
        case .other:
            subscriptionIcon(systemName: "bag.fill", colors: [.gray, .secondary])
        }
    }

    private func subscriptionIcon(systemName: String, colors: [Color]) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(
                LinearGradient(
                    colors: colors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }

    private func promoLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: CardStyle.promoTextFontSize, weight: .medium))
            .foregroundColor(promoColor)
    }

    private var priceSection: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(price)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)

            Text(billingPeriod)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.secondary)
        }
    }

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 0) {
                HStack(alignment: .top, spacing: CardStyle.contentSpacing) {
                    selectionIndicator
                    titleSection
                    Spacer()
                    priceSection
                }
                .padding(.horizontal, CardStyle.horizontalPadding)
                .padding(.vertical, CardStyle.verticalPadding)
                
                // Description at bottom after divider
                if let description = description {
                    Divider()
                        .padding(.horizontal, CardStyle.horizontalPadding)
                    
                    Text(description)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, CardStyle.horizontalPadding)
                        .padding(.vertical, 12)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: CardStyle.cornerRadius)
                    .fill(isSelected ? Color.blue.opacity(0.06) : Color.platformSecondaryBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: CardStyle.cornerRadius)
                            .stroke(isSelected ? Color.blue.opacity(0.4) : Color.gray.opacity(0.15),
                                    lineWidth: isSelected ? CardStyle.selectedStrokeWidth : CardStyle.unselectedStrokeWidth)
                    )
            )
            .overlay(alignment: .topTrailing) {
                // Badge overlay at top-right corner above price
                if let badge = badge {
                    Text(badge)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(badgeColor ?? Color.blue)
                        )
                        .offset(y: -8)
                        .padding(.trailing, 10)
                }
            }
        }
        .platformButtonStyle()
        .scaleEffect(isSelected ? CardStyle.selectedScale : 1.0)
        .animation(.easeInOut(duration: CardStyle.animationDuration), value: isSelected)
        .platformHoverEffect()
    }
}



// MARK: - Preview

#Preview("Purchase Option Cards") {
    VStack(spacing: 20) {
        VStack(spacing: 8) {
            Text("PurchaseOptionCard Preview")
                .font(.title2.bold())
            
            Text("Different states and configurations")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        
        VStack(spacing: 12) {
            // Weekly subscription
            PurchaseOptionCardView(
                title: "Pro Weekly",
                price: "$0.99",
                billingPeriod: "Weekly",
                badge: nil,
                badgeColor: nil,
                features: nil,
                promoText: nil,
                promoColor: .orange,
                introductoryOffer: nil,
                description: "Weekly subscription",
                productIconType: .weekly,
                isSelected: false,
                onSelect: { print("Selected: Pro Weekly") }
            )

            // Standard monthly subscription with trial
            PurchaseOptionCardView(
                title: "Pro Monthly",
                price: "$2.99",
                billingPeriod: "Monthly",
                badge: nil,
                badgeColor: nil,
                features: ["Cloud sync", "Premium filters"],
                promoText: nil,
                promoColor: .orange,
                introductoryOffer: "7 days free trial",
                description: "Monthly subscription",
                productIconType: .monthly,
                isSelected: false,
                onSelect: { print("Selected: Pro Monthly") }
            )

            // Popular annual plan with promo and pay-as-you-go intro
            PurchaseOptionCardView(
                title: "Pro Annual",
                price: "$19.99",
                billingPeriod: "Yearly",
                badge: "Popular",
                badgeColor: .orange,
                features: ["Cloud sync", "Premium filters", "Priority support"],
                promoText: "Save 44%",
                promoColor: .orange,
                introductoryOffer: nil,
                description: "Annual subscription",
                productIconType: .yearly,
                isSelected: true,
                onSelect: { print("Selected: Pro Annual") }
            )

            // Lifetime purchase option (no intro offer)
            PurchaseOptionCardView(
                title: "Pro Lifetime",
                price: "$29.99",
                billingPeriod: "Lifetime",
                badge: "Best Value",
                badgeColor: .blue,
                features: ["All features included", "Lifetime updates"],
                promoText: nil,
                promoColor: .orange,
                introductoryOffer: nil,
                description: "One-time purchase • Lifetime access",
                productIconType: .lifetime,
                isSelected: false,
                onSelect: { print("Selected: Pro Lifetime") }
            )
        }
        
        VStack(spacing: 4) {
            Text("Features Demonstrated:")
                .font(.caption.bold())
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("• Selection states (selected/unselected)")
                Text("• Introductory offers (free trial, discounted pricing)")
                Text("• Marketing badges (Most Popular, Best Value)")
                Text("• Savings indicators (Save 30%)")
                Text("• Feature lists with bullet points")
                Text("• Different product types (subscription, lifetime)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .font(.caption2)
            .foregroundColor(.secondary)
        }
        .padding(.top, 8)
    }
    .padding()
    .background(Color.platformBackground)
}

