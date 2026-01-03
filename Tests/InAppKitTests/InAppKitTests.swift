import Testing
import SwiftUI
@testable import InAppKit

// MARK: - Test Feature Definition

enum TestFeature: String, AppFeature, CaseIterable {
    case sync = "sync"
    case export = "export"
    case premium = "premium"
}

// MARK: - ProductDefinition Tests

struct ProductDefinitionTests {

    @Test func `product without features has empty feature list`() {
        let product = Product("com.test.simple")

        #expect(product.id == "com.test.simple")
        #expect(product.features.isEmpty)
        #expect(type(of: product) == ProductDefinition<String>.self)
    }

    @Test func `product with single enum feature`() {
        let product = Product("com.test.basic", features: [TestFeature.sync])

        #expect(product.id == "com.test.basic")
        #expect(product.features.count == 1)
        #expect(product.features.contains(TestFeature.sync))
        #expect(type(of: product) == ProductDefinition<TestFeature>.self)
    }

    @Test func `product with multiple enum features`() {
        let product = Product("com.test.pro", features: [TestFeature.sync, TestFeature.export, TestFeature.premium])

        #expect(product.id == "com.test.pro")
        #expect(product.features.count == 3)
        #expect(product.features.contains(TestFeature.sync))
        #expect(product.features.contains(TestFeature.export))
        #expect(product.features.contains(TestFeature.premium))
    }

    @Test func `product with allCases includes all features`() {
        let product = Product("com.test.premium", features: TestFeature.allCases)

        #expect(product.id == "com.test.premium")
        #expect(product.features.count == TestFeature.allCases.count)

        for feature in TestFeature.allCases {
            #expect(product.features.contains(feature))
        }
    }

    @Test func `product with string features`() {
        let product = Product("com.test.string", features: ["feature1", "feature2"])

        #expect(product.id == "com.test.string")
        #expect(product.features.count == 2)
        #expect(product.features.contains("feature1"))
        #expect(product.features.contains("feature2"))
        #expect(type(of: product) == ProductDefinition<String>.self)
    }
}

// MARK: - ProductDefinition Marketing Tests

struct ProductDefinitionMarketingTests {

    @Test func `product with badge`() {
        let product = Product("com.test.pro", features: [TestFeature.sync])
            .withBadge("Best Value")

        #expect(product.badge == "Best Value")
        #expect(product.badgeColor == nil)
    }

    @Test func `product with badge and custom color`() {
        let product = Product("com.test.pro", features: [TestFeature.sync])
            .withBadge("Popular", color: .orange)

        #expect(product.badge == "Popular")
        #expect(product.badgeColor == .orange)
    }

    @Test func `product with marketing features`() {
        let product = Product("com.test.pro", features: [TestFeature.sync])
            .withMarketingFeatures(["Cloud sync", "Premium support", "No ads"])

        #expect(product.marketingFeatures?.count == 3)
        #expect(product.marketingFeatures?.contains("Cloud sync") == true)
    }

    @Test func `product with promo text`() {
        let product = Product("com.test.yearly", features: [TestFeature.sync])
            .withPromoText("Save 44%")

        #expect(product.promoText == "Save 44%")
    }

    @Test func `product with all marketing properties chained`() {
        let product = Product("com.test.yearly", features: [TestFeature.sync])
            .withBadge("Best Value", color: .blue)
            .withPromoText("Save $44")
            .withMarketingFeatures(["Cloud sync", "Premium support"])

        #expect(product.badge == "Best Value")
        #expect(product.badgeColor == .blue)
        #expect(product.promoText == "Save $44")
        #expect(product.marketingFeatures?.count == 2)
    }
}

// MARK: - DiscountRule Tests

struct DiscountRuleTests {

    @Test func `relative discount with default percentage style`() {
        let product = Product("com.test.yearly", features: [TestFeature.sync])
            .withRelativeDiscount(comparedTo: "com.test.monthly")

        #expect(product.discountRule != nil)
        #expect(product.discountRule?.comparedTo == "com.test.monthly")
        #expect(product.discountRule?.style == .percentage)
        #expect(product.discountRule?.color == nil)
    }

    @Test func `relative discount with amount style`() {
        let product = Product("com.test.yearly", features: [TestFeature.sync])
            .withRelativeDiscount(comparedTo: "com.test.monthly", style: .amount)

        #expect(product.discountRule?.style == .amount)
    }

    @Test func `relative discount with free time style`() {
        let product = Product("com.test.yearly", features: [TestFeature.sync])
            .withRelativeDiscount(comparedTo: "com.test.monthly", style: .freeTime)

        #expect(product.discountRule?.style == .freeTime)
    }

    @Test func `relative discount with custom color`() {
        let product = Product("com.test.yearly", features: [TestFeature.sync])
            .withRelativeDiscount(comparedTo: "com.test.monthly", style: .percentage, color: .green)

        #expect(product.discountRule?.color == .green)
    }

    @Test func `relative discount preserves other properties`() {
        let product = Product("com.test.yearly", features: [TestFeature.sync])
            .withBadge("Best Value")
            .withPromoText("Save $44")
            .withMarketingFeatures(["Cloud sync", "Premium support"])
            .withRelativeDiscount(comparedTo: "com.test.monthly")

        #expect(product.badge == "Best Value")
        #expect(product.promoText == "Save $44")
        #expect(product.marketingFeatures?.count == 2)
        #expect(product.discountRule != nil)
    }
}

// MARK: - PurchaseSetup Tests

struct PurchaseSetupTests {

    @Test @MainActor func `configuration with single product id`() {
        let config = PurchaseSetup()
            .withPurchases("com.test.pro")

        #expect(config.productConfigs.count == 1)
        #expect(config.productConfigs.first?.id == "com.test.pro")
    }

    @Test @MainActor func `configuration with variadic product ids`() {
        let config = PurchaseSetup()
            .withPurchases("com.test.pro1", "com.test.pro2", "com.test.pro3")

        #expect(config.productConfigs.count == 3)
        #expect(config.productConfigs[0].id == "com.test.pro1")
        #expect(config.productConfigs[1].id == "com.test.pro2")
        #expect(config.productConfigs[2].id == "com.test.pro3")
    }

    @Test @MainActor func `configuration with product array`() {
        let config = PurchaseSetup()
            .withPurchases(products: [
                Product("com.test.pro", features: [TestFeature.sync, TestFeature.export]),
                Product("com.test.premium", features: [TestFeature.premium])
            ])

        #expect(config.productConfigs.count == 2)
        #expect(config.productConfigs[0].id == "com.test.pro")
        #expect(config.productConfigs[1].id == "com.test.premium")
    }

    @Test @MainActor func `configuration with mixed product types`() {
        let config = PurchaseSetup()
            .withPurchases(products: [
                Product("com.test.basic", features: [TestFeature.sync, TestFeature.export, TestFeature.premium]),
                Product("com.test.premium", features: TestFeature.allCases),
                Product("com.test.premium1", features: ["some-feature"]),
                Product("com.test.basic1")
            ])

        #expect(config.productConfigs.count == 4)
        #expect(config.productConfigs[0].features.count == 3)
        #expect(config.productConfigs[1].features.count == 3)
        #expect(config.productConfigs[2].features.count == 1)
        #expect(config.productConfigs[3].features.isEmpty)
    }

    @Test @MainActor func `configuration with relative discount`() {
        let config = PurchaseSetup()
            .withPurchases(products: [
                Product("com.test.monthly", features: [TestFeature.sync]),
                Product("com.test.yearly", features: [TestFeature.sync])
                    .withRelativeDiscount(comparedTo: "com.test.monthly")
            ])

        #expect(config.productConfigs.count == 2)
        #expect(config.productConfigs[0].discountRule == nil)
        #expect(config.productConfigs[1].discountRule != nil)
        #expect(config.productConfigs[1].discountRule?.comparedTo == "com.test.monthly")
    }
}

// MARK: - PurchaseSetup Paywall Tests

struct PurchaseSetupPaywallTests {

    @Test @MainActor func `configuration with custom paywall builder`() {
        var paywallCalled = false

        let config = PurchaseSetup()
            .withPurchases("com.test.pro")
            .withPaywall { context in
                paywallCalled = true
                return Text("Custom Paywall")
            }

        #expect(config.paywallBuilder != nil)

        let context = PaywallContext()
        _ = config.paywallBuilder?(context)
        #expect(paywallCalled)
    }

    @Test @MainActor func `configuration with terms builder`() {
        var termsCalled = false

        let config = PurchaseSetup()
            .withPurchases("com.test.pro")
            .withTerms {
                termsCalled = true
                return Text("Custom Terms")
            }

        #expect(config.termsBuilder != nil)
        _ = config.termsBuilder?()
        #expect(termsCalled)
    }

    @Test @MainActor func `configuration with privacy builder`() {
        var privacyCalled = false

        let config = PurchaseSetup()
            .withPurchases("com.test.pro")
            .withPrivacy {
                privacyCalled = true
                return Text("Custom Privacy")
            }

        #expect(config.privacyBuilder != nil)
        _ = config.privacyBuilder?()
        #expect(privacyCalled)
    }

    @Test @MainActor func `configuration with terms URL`() {
        let termsURL = URL(string: "https://example.com/terms")!

        let config = PurchaseSetup()
            .withPurchases("com.test.pro")
            .withTerms(url: termsURL)

        #expect(config.termsURL == termsURL)
    }

    @Test @MainActor func `configuration with privacy URL`() {
        let privacyURL = URL(string: "https://example.com/privacy")!

        let config = PurchaseSetup()
            .withPurchases("com.test.pro")
            .withPrivacy(url: privacyURL)

        #expect(config.privacyURL == privacyURL)
    }

    @Test @MainActor func `configuration with all legal URLs`() {
        let termsURL = URL(string: "https://example.com/terms")!
        let privacyURL = URL(string: "https://example.com/privacy")!

        let config = PurchaseSetup()
            .withPurchases("com.test.pro")
            .withTerms(url: termsURL)
            .withPrivacy(url: privacyURL)

        #expect(config.termsURL == termsURL)
        #expect(config.privacyURL == privacyURL)
    }
}

// MARK: - PaywallContext Tests

struct PaywallContextTests {

    @Test @MainActor func `context initializes with trigger`() {
        let context = PaywallContext(
            triggeredBy: "test_feature",
            availableProducts: [],
            recommendedProduct: nil
        )

        #expect(context.triggeredBy == "test_feature")
        #expect(context.availableProducts.isEmpty)
        #expect(context.recommendedProduct == nil)
    }

    @Test @MainActor func `context with empty products has empty marketing list`() {
        let context = PaywallContext(
            triggeredBy: "test_feature",
            availableProducts: [],
            recommendedProduct: nil
        )

        #expect(context.productsWithMarketing.isEmpty)
    }
}

// MARK: - InAppKit Feature Tests

struct InAppKitFeatureTests {

    @Test @MainActor func `register feature maps feature to products`() {
        let manager = InAppKit.shared
        manager.registerFeature(TestFeature.sync, productIds: ["com.test.pro"])

        #expect(manager.isFeatureRegistered(TestFeature.sync))
    }

    @Test @MainActor func `unregistered feature returns false`() {
        let manager = InAppKit.shared

        // Use a unique string feature that is never registered elsewhere
        #expect(!manager.isFeatureRegistered("never_registered_feature_xyz"))
    }

    @Test @MainActor func `hasAccess returns false without purchase`() {
        let manager = InAppKit.shared
        manager.registerFeature(TestFeature.premium, productIds: ["com.test.premium"])

        #expect(!manager.hasAccess(to: TestFeature.premium))
    }

    @Test @MainActor func `isPurchased returns false for unpurchased product`() {
        let manager = InAppKit.shared

        #expect(!manager.isPurchased("com.test.nonexistent"))
    }

    @Test @MainActor func `hasAnyPurchase returns false when empty`() {
        let manager = InAppKit.shared
        manager.clearPurchases()

        #expect(!manager.hasAnyPurchase)
    }

    #if DEBUG
    @Test @MainActor func `simulatePurchase adds product to purchased set`() {
        let manager = InAppKit.shared
        manager.clearPurchases()

        manager.simulatePurchase("com.test.simulated")

        #expect(manager.isPurchased("com.test.simulated"))
        #expect(manager.hasAnyPurchase)

        manager.clearPurchases()
    }

    @Test @MainActor func `clearPurchases removes all purchased products`() {
        let manager = InAppKit.shared
        manager.simulatePurchase("com.test.product1")
        manager.simulatePurchase("com.test.product2")

        manager.clearPurchases()

        #expect(!manager.isPurchased("com.test.product1"))
        #expect(!manager.isPurchased("com.test.product2"))
        #expect(!manager.hasAnyPurchase)
    }

    @Test @MainActor func `hasAccess returns true after simulated purchase`() {
        let manager = InAppKit.shared
        manager.clearPurchases()
        manager.registerFeature(TestFeature.sync, productIds: ["com.test.pro"])

        manager.simulatePurchase("com.test.pro")

        #expect(manager.hasAccess(to: TestFeature.sync))

        manager.clearPurchases()
    }
    #endif
}

// MARK: - InAppKit Feature Access Scenarios

struct InAppKitFeatureAccessTests {

    #if DEBUG
    @Test @MainActor func `hasAccess falls back to hasAnyPurchase when feature not registered`() {
        let manager = InAppKit.shared
        manager.clearPurchases()

        // Feature "unknown_feature" is not registered
        // With no purchases, should return false
        #expect(!manager.hasAccess(to: "unknown_feature"))

        // With any purchase, should return true (fallback behavior)
        manager.simulatePurchase("com.test.any_product")
        #expect(manager.hasAccess(to: "unknown_feature"))

        manager.clearPurchases()
    }

    @Test @MainActor func `hasAccess returns false when user has wrong product`() {
        let manager = InAppKit.shared
        manager.clearPurchases()

        // Register feature to specific product
        manager.registerFeature(TestFeature.export, productIds: ["com.test.export_product"])

        // User purchased different product
        manager.simulatePurchase("com.test.different_product")

        // Should NOT have access (wrong product)
        #expect(!manager.hasAccess(to: TestFeature.export))

        manager.clearPurchases()
    }

    @Test @MainActor func `hasAccess returns true when feature has multiple products and user owns one`() {
        let manager = InAppKit.shared
        manager.clearPurchases()

        // Feature available in multiple products (e.g., sync in both pro and premium)
        manager.registerFeature(TestFeature.sync, productIds: ["com.test.pro", "com.test.premium"])

        // User only purchased one of them
        manager.simulatePurchase("com.test.premium")

        // Should have access
        #expect(manager.hasAccess(to: TestFeature.sync))

        manager.clearPurchases()
    }

    @Test @MainActor func `register multiple features to same product`() {
        let manager = InAppKit.shared
        manager.clearPurchases()

        // One product provides multiple features
        manager.registerFeature(TestFeature.sync, productIds: ["com.test.pro"])
        manager.registerFeature(TestFeature.export, productIds: ["com.test.pro"])
        manager.registerFeature(TestFeature.premium, productIds: ["com.test.pro"])

        manager.simulatePurchase("com.test.pro")

        // Should have access to all features
        #expect(manager.hasAccess(to: TestFeature.sync))
        #expect(manager.hasAccess(to: TestFeature.export))
        #expect(manager.hasAccess(to: TestFeature.premium))

        manager.clearPurchases()
    }

    @Test @MainActor func `isFeatureRegistered with AnyHashable`() {
        let manager = InAppKit.shared

        manager.registerFeature(AnyHashable("string_feature"), productIds: ["com.test.pro"])

        #expect(manager.isFeatureRegistered(AnyHashable("string_feature")))
        #expect(!manager.isFeatureRegistered(AnyHashable("unregistered")))
    }

    @Test @MainActor func `hasAccess with generic hashable type`() {
        let manager = InAppKit.shared
        manager.clearPurchases()

        manager.registerFeature("string_feature", productIds: ["com.test.string"])
        manager.simulatePurchase("com.test.string")

        #expect(manager.hasAccess(to: "string_feature"))

        manager.clearPurchases()
    }

    @Test @MainActor func `isPremium deprecated property returns same as hasAnyPurchase`() {
        let manager = InAppKit.shared
        manager.clearPurchases()

        #expect(manager.isPremium == manager.hasAnyPurchase)
        #expect(!manager.isPremium)

        manager.simulatePurchase("com.test.any")

        #expect(manager.isPremium == manager.hasAnyPurchase)
        #expect(manager.isPremium)

        manager.clearPurchases()
    }
    #endif
}

// MARK: - InAppKit Marketing Info Tests

struct InAppKitMarketingInfoTests {

    @Test @MainActor func `badge returns nil for unconfigured product`() {
        let manager = InAppKit.shared

        #expect(manager.badge(for: "com.test.unknown") == nil)
    }

    @Test @MainActor func `badgeColor returns nil for unconfigured product`() {
        let manager = InAppKit.shared

        #expect(manager.badgeColor(for: "com.test.unknown") == nil)
    }

    @Test @MainActor func `marketingFeatures returns nil for unconfigured product`() {
        let manager = InAppKit.shared

        #expect(manager.marketingFeatures(for: "com.test.unknown") == nil)
    }

    @Test @MainActor func `promoText returns nil for unconfigured product`() {
        let manager = InAppKit.shared

        #expect(manager.promoText(for: "com.test.unknown") == nil)
    }

    @Test @MainActor func `discountRule returns nil for unconfigured product`() {
        let manager = InAppKit.shared

        #expect(manager.discountRule(for: "com.test.unknown") == nil)
    }
}

// MARK: - StoreError Tests

struct StoreErrorTests {

    @Test func `failedVerification error has correct message`() {
        let error = StoreError.failedVerification

        #expect(error.localizedDescription.contains("verification failed"))
    }

    @Test func `productNotFound error includes product id`() {
        let error = StoreError.productNotFound("com.test.missing")

        #expect(error.localizedDescription.contains("com.test.missing"))
    }

    @Test func `purchaseInProgress error has correct message`() {
        let error = StoreError.purchaseInProgress

        #expect(error.localizedDescription.contains("already in progress"))
    }

    @Test func `userCancelled error has correct message`() {
        let error = StoreError.userCancelled

        #expect(error.localizedDescription.contains("cancelled"))
    }

    @Test func `networkError has correct message`() {
        let underlyingError = NSError(domain: "test", code: -1009, userInfo: [NSLocalizedDescriptionKey: "No internet"])
        let error = StoreError.networkError(underlyingError)

        #expect(error.localizedDescription.contains("Network error"))
        #expect(error.localizedDescription.contains("connection"))
    }

    @Test func `unknownError wraps underlying error`() {
        let underlyingError = NSError(domain: "test", code: 500, userInfo: [NSLocalizedDescriptionKey: "Server error"])
        let error = StoreError.unknownError(underlyingError)

        #expect(error.localizedDescription.contains("unexpected error"))
        #expect(error.localizedDescription.contains("Server error"))
    }
}

// MARK: - InternalProductConfig Tests

struct InternalProductDefinitionTests {

    @Test func `toInternal converts ProductDefinition with all properties`() {
        let product = Product("com.test.yearly", features: [TestFeature.sync, TestFeature.export])
            .withBadge("Best Value", color: .blue)
            .withPromoText("Save 44%")
            .withMarketingFeatures(["Cloud sync", "Premium support"])
            .withRelativeDiscount(comparedTo: "com.test.monthly", style: .percentage, color: .green)

        let config = product.toInternal()

        #expect(config.id == "com.test.yearly")
        #expect(config.features.count == 2)
        #expect(config.badge == "Best Value")
        #expect(config.badgeColor == .blue)
        #expect(config.promoText == "Save 44%")
        #expect(config.marketingFeatures?.count == 2)
        #expect(config.discountRule?.comparedTo == "com.test.monthly")
        #expect(config.discountRule?.style == .percentage)
        #expect(config.discountRule?.color == .green)
    }

    @Test func `toInternal converts ProductDefinition with minimal properties`() {
        let product = Product("com.test.basic")

        let config = product.toInternal()

        #expect(config.id == "com.test.basic")
        #expect(config.features.isEmpty)
        #expect(config.badge == nil)
        #expect(config.badgeColor == nil)
        #expect(config.promoText == nil)
        #expect(config.marketingFeatures == nil)
        #expect(config.discountRule == nil)
    }

    @Test func `toInternal converts features to AnyHashable`() {
        let product = Product("com.test.pro", features: [TestFeature.sync, TestFeature.premium])

        let config = product.toInternal()

        // Features should be converted to AnyHashable
        #expect(config.features.count == 2)
        #expect(config.features.contains(AnyHashable(TestFeature.sync)))
        #expect(config.features.contains(AnyHashable(TestFeature.premium)))
    }

    @Test func `toInternal with string features`() {
        let product = Product("com.test.string", features: ["feature_a", "feature_b"])

        let config = product.toInternal()

        #expect(config.features.count == 2)
        #expect(config.features.contains(AnyHashable("feature_a")))
        #expect(config.features.contains(AnyHashable("feature_b")))
    }
}

// MARK: - AppFeature Protocol Tests

struct AppFeatureProtocolTests {

    @Test func `feature rawValue matches enum case`() {
        #expect(TestFeature.sync.rawValue == "sync")
        #expect(TestFeature.export.rawValue == "export")
        #expect(TestFeature.premium.rawValue == "premium")
    }

    @Test func `feature conforms to CaseIterable`() {
        #expect(TestFeature.allCases.count == 3)
    }
}

// MARK: - View Extension Tests

struct ViewExtensionTests {

    @Test @MainActor func `requiresPurchase modifiers compile correctly`() {
        let baseView = Text("Test")

        let premiumView = baseView.requiresPurchase()
        let productView = baseView.requiresPurchase("com.test.pro")
        let featureView = baseView.requiresPurchase(TestFeature.sync)
        let conditionalView = baseView.requiresPurchase(when: true)

        #expect(type(of: premiumView) != type(of: baseView))
        #expect(type(of: productView) != type(of: baseView))
        #expect(type(of: featureView) != type(of: baseView))
        #expect(type(of: conditionalView) != type(of: baseView))
    }
}

// MARK: - PurchaseEnabledView Tests

struct PurchaseEnabledViewTests {

    @Test @MainActor func `chained view has correct type`() {
        let baseView = Text("Test Content")

        let chainedView = baseView
            .withPurchases(products: [
                Product("com.test.pro", features: [TestFeature.sync, TestFeature.export])
            ])
            .withPaywall { context in
                Text("Custom Paywall - \(context.triggeredBy ?? "unknown")")
            }
            .withTerms {
                Text("Custom Terms")
            }
            .withPrivacy {
                Text("Custom Privacy")
            }

        #expect(type(of: chainedView) == PurchaseEnabledView<Text>.self)
    }

    @Test @MainActor func `chained view preserves configuration`() {
        let baseView = Text("Test Content")

        let chainedView = baseView
            .withPurchases(products: [
                Product("com.test.pro", features: [TestFeature.sync])
            ])
            .withPaywall { _ in Text("Paywall") }
            .withTerms { Text("Terms") }
            .withPrivacy { Text("Privacy") }

        #expect(chainedView.config.productConfigs.count == 1)
        #expect(chainedView.config.productConfigs.first?.id == "com.test.pro")
        #expect(chainedView.config.paywallBuilder != nil)
        #expect(chainedView.config.termsBuilder != nil)
        #expect(chainedView.config.privacyBuilder != nil)
    }

    @Test @MainActor func `chained view without paywall still has terms and privacy`() {
        let baseView = Text("Test Content")

        let chainedView = baseView
            .withPurchases(products: [
                Product("com.test.pro", features: [TestFeature.sync])
            ])
            .withTerms { Text("Custom Terms") }
            .withPrivacy { Text("Custom Privacy") }

        #expect(chainedView.config.productConfigs.count == 1)
        #expect(chainedView.config.paywallBuilder == nil)
        #expect(chainedView.config.termsBuilder != nil)
        #expect(chainedView.config.privacyBuilder != nil)
    }

    @Test @MainActor func `chained view with single product id`() {
        let baseView = Text("Test")

        let chainedView = baseView
            .withPurchases("com.test.pro")
            .withPaywall { _ in Text("Simple Paywall") }

        #expect(type(of: chainedView) == PurchaseEnabledView<Text>.self)
        #expect(chainedView.config.productConfigs.count == 1)
        #expect(chainedView.config.productConfigs.first?.id == "com.test.pro")
    }

    @Test @MainActor func `chained view with relative discount`() {
        let baseView = Text("Premium Content")

        let chainedView = baseView
            .withPurchases(products: [
                Product("com.test.monthly", features: [TestFeature.sync]),
                Product("com.test.yearly", features: [TestFeature.sync])
                    .withRelativeDiscount(comparedTo: "com.test.monthly", style: .percentage)
            ])
            .withPaywall { _ in Text("Upgrade Now") }

        #expect(chainedView.config.productConfigs.count == 2)
        #expect(chainedView.config.productConfigs[1].discountRule?.style == .percentage)
    }

    @Test @MainActor func `chained view with URL-based terms and privacy`() {
        let baseView = Text("Test Content")
        let termsURL = URL(string: "https://example.com/terms")!
        let privacyURL = URL(string: "https://example.com/privacy")!

        let chainedView = baseView
            .withPurchases(products: [Product("com.test.pro")])
            .withTerms(url: termsURL)
            .withPrivacy(url: privacyURL)

        #expect(chainedView.config.termsURL == termsURL)
        #expect(chainedView.config.privacyURL == privacyURL)
    }
}

// MARK: - Convenience Extensions Tests

struct ConvenienceExtensionsTests {

    @Test func `mb extension calculates correct bytes`() {
        let size5MB = 5.mb
        let size10MB = 10.MB

        #expect(size5MB == 5 * 1024 * 1024)
        #expect(size10MB == 10 * 1024 * 1024)
    }
}