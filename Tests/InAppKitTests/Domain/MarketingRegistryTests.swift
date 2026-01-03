import Testing
import SwiftUI
@testable import InAppKit

@Suite
struct MarketingRegistryTests {

    // MARK: - Creating Registry

    @Test
    func `empty registry has no products`() {
        // Given
        let registry = MarketingRegistry()

        // Then
        #expect(registry.allProductIds.isEmpty)
    }

    // MARK: - Registering Marketing Info

    @Test
    func `register marketing info for product`() {
        // Given
        let registry = MarketingRegistry()
        let marketing = ProductMarketing(
            badge: "Best Value",
            badgeColor: .blue,
            features: ["Cloud sync", "Premium support"],
            promoText: "Save 44%"
        )

        // When
        let newRegistry = registry.withMarketing("com.app.pro", marketing: marketing)

        // Then
        #expect(newRegistry.badge(for: "com.app.pro") == "Best Value")
        #expect(newRegistry.badgeColor(for: "com.app.pro") == .blue)
        #expect(newRegistry.features(for: "com.app.pro")?.count == 2)
        #expect(newRegistry.promoText(for: "com.app.pro") == "Save 44%")
    }

    @Test
    func `register marketing with discount rule`() {
        // Given
        let registry = MarketingRegistry()
        let discountConfig = DiscountRule(
            comparedTo: "com.app.monthly",
            style: .percentage,
            color: .green
        )
        let marketing = ProductMarketing(
            badge: "Popular",
            discountRule: discountConfig
        )

        // When
        let newRegistry = registry.withMarketing("com.app.yearly", marketing: marketing)

        // Then
        let config = newRegistry.discountRule(for: "com.app.yearly")
        #expect(config?.comparedTo == "com.app.monthly")
        #expect(config?.style == .percentage)
        #expect(config?.color == .green)
    }

    // MARK: - Querying Registry

    @Test
    func `badge returns nil for unknown product`() {
        // Given
        let registry = MarketingRegistry()

        // Then
        #expect(registry.badge(for: "com.app.unknown") == nil)
    }

    @Test
    func `marketing returns nil for unknown product`() {
        // Given
        let registry = MarketingRegistry()

        // Then
        #expect(registry.marketing(for: "com.app.unknown") == nil)
    }

    @Test
    func `allProductIds returns all registered products`() {
        // Given
        let registry = MarketingRegistry()
            .withMarketing("com.app.pro", marketing: ProductMarketing(badge: "Pro"))
            .withMarketing("com.app.premium", marketing: ProductMarketing(badge: "Premium"))

        // Then
        #expect(registry.allProductIds.count == 2)
        #expect(registry.allProductIds.contains("com.app.pro"))
        #expect(registry.allProductIds.contains("com.app.premium"))
    }

    @Test
    func `productsWithBadges returns only products with badges`() {
        // Given
        let registry = MarketingRegistry()
            .withMarketing("com.app.pro", marketing: ProductMarketing(badge: "Best Value"))
            .withMarketing("com.app.basic", marketing: ProductMarketing(features: ["Basic feature"]))
            .withMarketing("com.app.premium", marketing: ProductMarketing(badge: "Popular"))

        // Then
        let badgeProducts = registry.productsWithBadges
        #expect(badgeProducts.count == 2)
        #expect(badgeProducts.contains("com.app.pro"))
        #expect(badgeProducts.contains("com.app.premium"))
        #expect(!badgeProducts.contains("com.app.basic"))
    }

    // MARK: - ProductMarketing Domain Behavior

    @Test
    func `hasMarketing is true when badge is set`() {
        // Given
        let marketing = ProductMarketing(badge: "Sale")

        // Then
        #expect(marketing.hasMarketing)
    }

    @Test
    func `hasMarketing is true when features are set`() {
        // Given
        let marketing = ProductMarketing(features: ["Feature 1"])

        // Then
        #expect(marketing.hasMarketing)
    }

    @Test
    func `hasMarketing is true when promoText is set`() {
        // Given
        let marketing = ProductMarketing(promoText: "Save 50%")

        // Then
        #expect(marketing.hasMarketing)
    }

    @Test
    func `hasMarketing is false when empty`() {
        // Given
        let marketing = ProductMarketing()

        // Then
        #expect(!marketing.hasMarketing)
    }

    @Test
    func `hasBadge is true when badge is set`() {
        // Given
        let marketing = ProductMarketing(badge: "Popular")

        // Then
        #expect(marketing.hasBadge)
    }

    @Test
    func `hasDiscountRule is true when rule is set`() {
        // Given
        let marketing = ProductMarketing(
            discountRule: DiscountRule(
                comparedTo: "com.app.monthly",
                style: .percentage
            )
        )

        // Then
        #expect(marketing.hasDiscountRule)
    }

    // MARK: - Removing Marketing

    @Test
    func `withoutMarketing removes product`() {
        // Given
        let registry = MarketingRegistry()
            .withMarketing("com.app.pro", marketing: ProductMarketing(badge: "Pro"))
            .withMarketing("com.app.premium", marketing: ProductMarketing(badge: "Premium"))

        // When
        let newRegistry = registry.withoutMarketing(for: "com.app.pro")

        // Then
        #expect(newRegistry.badge(for: "com.app.pro") == nil)
        #expect(newRegistry.badge(for: "com.app.premium") == "Premium")
    }

    @Test
    func `cleared removes all marketing`() {
        // Given
        let registry = MarketingRegistry()
            .withMarketing("com.app.pro", marketing: ProductMarketing(badge: "Pro"))
            .withMarketing("com.app.premium", marketing: ProductMarketing(badge: "Premium"))

        // When
        let newRegistry = registry.cleared()

        // Then
        #expect(newRegistry.allProductIds.isEmpty)
    }

    // MARK: - Immutability

    @Test
    func `original registry unchanged after adding marketing`() {
        // Given
        let original = MarketingRegistry()

        // When
        let _ = original.withMarketing("com.app.pro", marketing: ProductMarketing(badge: "Pro"))

        // Then
        #expect(original.allProductIds.isEmpty) // Original unchanged
    }

    // MARK: - Bulk Registration from Config

    @Test
    func `withMarketing from InternalProductConfig`() {
        // Given
        let registry = MarketingRegistry()
        let config = InternalProductConfig(
            id: "com.app.yearly",
            features: [],
            badge: "Best Value",
            badgeColor: .blue,
            marketingFeatures: ["Cloud sync", "Premium support"],
            promoText: "Save 44%",
            discountRule: nil
        )

        // When
        let newRegistry = registry.withMarketing(from: config)

        // Then
        #expect(newRegistry.badge(for: "com.app.yearly") == "Best Value")
        #expect(newRegistry.badgeColor(for: "com.app.yearly") == .blue)
        #expect(newRegistry.features(for: "com.app.yearly")?.count == 2)
        #expect(newRegistry.promoText(for: "com.app.yearly") == "Save 44%")
    }

    @Test
    func `withMarketing from multiple configs`() {
        // Given
        let registry = MarketingRegistry()
        let configs = [
            InternalProductConfig(
                id: "com.app.monthly",
                features: [],
                badge: nil,
                badgeColor: nil,
                marketingFeatures: nil,
                promoText: nil,
                discountRule: nil
            ),
            InternalProductConfig(
                id: "com.app.yearly",
                features: [],
                badge: "Best Value",
                badgeColor: .blue,
                marketingFeatures: nil,
                promoText: "Save 44%",
                discountRule: nil
            )
        ]

        // When
        let newRegistry = registry.withMarketing(from: configs)

        // Then
        #expect(newRegistry.allProductIds.count == 2)
        #expect(newRegistry.badge(for: "com.app.yearly") == "Best Value")
    }
}
