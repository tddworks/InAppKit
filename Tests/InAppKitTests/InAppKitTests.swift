import Testing
import SwiftUI
@testable import InAppKit

// MARK: - Test Feature Definition

enum TestFeature: String, AppFeature, CaseIterable {
    case sync = "sync"
    case export = "export"
    case premium = "premium"
}

// MARK: - ProductConfig Tests

struct ProductConfigTests {

    @Test func `product without features has empty feature list`() {
        let product = Product("com.test.simple")

        #expect(product.id == "com.test.simple")
        #expect(product.features.isEmpty)
        #expect(type(of: product) == ProductConfig<String>.self)
    }

    @Test func `product with single enum feature`() {
        let product = Product("com.test.basic", features: [TestFeature.sync])

        #expect(product.id == "com.test.basic")
        #expect(product.features.count == 1)
        #expect(product.features.contains(TestFeature.sync))
        #expect(type(of: product) == ProductConfig<TestFeature>.self)
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
        #expect(type(of: product) == ProductConfig<String>.self)
    }
}

// MARK: - ProductConfig Marketing Tests

struct ProductConfigMarketingTests {

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

// MARK: - RelativeDiscountConfig Tests

struct RelativeDiscountConfigTests {

    @Test func `relative discount with default percentage style`() {
        let product = Product("com.test.yearly", features: [TestFeature.sync])
            .withRelativeDiscount(comparedTo: "com.test.monthly")

        #expect(product.relativeDiscountConfig != nil)
        #expect(product.relativeDiscountConfig?.baseProductId == "com.test.monthly")
        #expect(product.relativeDiscountConfig?.style == .percentage)
        #expect(product.relativeDiscountConfig?.color == nil)
    }

    @Test func `relative discount with amount style`() {
        let product = Product("com.test.yearly", features: [TestFeature.sync])
            .withRelativeDiscount(comparedTo: "com.test.monthly", style: .amount)

        #expect(product.relativeDiscountConfig?.style == .amount)
    }

    @Test func `relative discount with free time style`() {
        let product = Product("com.test.yearly", features: [TestFeature.sync])
            .withRelativeDiscount(comparedTo: "com.test.monthly", style: .freeTime)

        #expect(product.relativeDiscountConfig?.style == .freeTime)
    }

    @Test func `relative discount with custom color`() {
        let product = Product("com.test.yearly", features: [TestFeature.sync])
            .withRelativeDiscount(comparedTo: "com.test.monthly", style: .percentage, color: .green)

        #expect(product.relativeDiscountConfig?.color == .green)
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
        #expect(product.relativeDiscountConfig != nil)
    }
}

// MARK: - StoreKitConfiguration Tests

struct StoreKitConfigurationTests {

    @Test @MainActor func `configuration with single product id`() {
        let config = StoreKitConfiguration()
            .withPurchases("com.test.pro")

        #expect(config.productConfigs.count == 1)
        #expect(config.productConfigs.first?.id == "com.test.pro")
    }

    @Test @MainActor func `configuration with variadic product ids`() {
        let config = StoreKitConfiguration()
            .withPurchases("com.test.pro1", "com.test.pro2", "com.test.pro3")

        #expect(config.productConfigs.count == 3)
        #expect(config.productConfigs[0].id == "com.test.pro1")
        #expect(config.productConfigs[1].id == "com.test.pro2")
        #expect(config.productConfigs[2].id == "com.test.pro3")
    }

    @Test @MainActor func `configuration with product array`() {
        let config = StoreKitConfiguration()
            .withPurchases(products: [
                Product("com.test.pro", features: [TestFeature.sync, TestFeature.export]),
                Product("com.test.premium", features: [TestFeature.premium])
            ])

        #expect(config.productConfigs.count == 2)
        #expect(config.productConfigs[0].id == "com.test.pro")
        #expect(config.productConfigs[1].id == "com.test.premium")
    }

    @Test @MainActor func `configuration with mixed product types`() {
        let config = StoreKitConfiguration()
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
        let config = StoreKitConfiguration()
            .withPurchases(products: [
                Product("com.test.monthly", features: [TestFeature.sync]),
                Product("com.test.yearly", features: [TestFeature.sync])
                    .withRelativeDiscount(comparedTo: "com.test.monthly")
            ])

        #expect(config.productConfigs.count == 2)
        #expect(config.productConfigs[0].relativeDiscountConfig == nil)
        #expect(config.productConfigs[1].relativeDiscountConfig != nil)
        #expect(config.productConfigs[1].relativeDiscountConfig?.baseProductId == "com.test.monthly")
    }
}

// MARK: - StoreKitConfiguration Paywall Tests

struct StoreKitConfigurationPaywallTests {

    @Test @MainActor func `configuration with custom paywall builder`() {
        var paywallCalled = false

        let config = StoreKitConfiguration()
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

        let config = StoreKitConfiguration()
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

        let config = StoreKitConfiguration()
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

        let config = StoreKitConfiguration()
            .withPurchases("com.test.pro")
            .withTerms(url: termsURL)

        #expect(config.termsURL == termsURL)
    }

    @Test @MainActor func `configuration with privacy URL`() {
        let privacyURL = URL(string: "https://example.com/privacy")!

        let config = StoreKitConfiguration()
            .withPurchases("com.test.pro")
            .withPrivacy(url: privacyURL)

        #expect(config.privacyURL == privacyURL)
    }

    @Test @MainActor func `configuration with all legal URLs`() {
        let termsURL = URL(string: "https://example.com/terms")!
        let privacyURL = URL(string: "https://example.com/privacy")!

        let config = StoreKitConfiguration()
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

        #expect(!manager.isFeatureRegistered(TestFeature.export))
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

    @Test @MainActor func `relativeDiscountConfig returns nil for unconfigured product`() {
        let manager = InAppKit.shared

        #expect(manager.relativeDiscountConfig(for: "com.test.unknown") == nil)
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

// MARK: - ChainableStoreKitView Tests

struct ChainableStoreKitViewTests {

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

        #expect(type(of: chainedView) == ChainableStoreKitView<Text>.self)
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

        #expect(type(of: chainedView) == ChainableStoreKitView<Text>.self)
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
        #expect(chainedView.config.productConfigs[1].relativeDiscountConfig?.style == .percentage)
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