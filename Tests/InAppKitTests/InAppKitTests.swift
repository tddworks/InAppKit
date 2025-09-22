import Testing
import SwiftUI
@testable import InAppKit

// MARK: - Test Feature Definition

enum TestFeature: String, AppFeature, CaseIterable {
    case sync = "sync"
    case export = "export"
    case premium = "premium"
}

struct InAppKitTests {
    
    @Test @MainActor func testFluentConfiguration() async throws {
        let config = StoreKitConfiguration()
            .withPurchases("com.test.pro")
        
        #expect(config.productConfigs.count == 1)
        #expect(config.productConfigs.first?.id == "com.test.pro")
    }
    
    @Test @MainActor func testComplexFluentConfiguration() async throws {
        let config = StoreKitConfiguration()
            .withPurchases(products: [
                Product("com.test.pro", features: [TestFeature.sync, TestFeature.export]),
                Product("com.test.premium", features: [TestFeature.premium])
            ])

        #expect(config.productConfigs.count == 2)
        #expect(config.productConfigs[0].id == "com.test.pro")
        #expect(config.productConfigs[1].id == "com.test.premium")
    }

    @Test @MainActor func testVariadicFluentConfiguration() async throws {
        let config = StoreKitConfiguration()
            .withPurchases("com.test.pro1", "com.test.pro2")

        #expect(config.productConfigs.count == 2)
        #expect(config.productConfigs[0].id == "com.test.pro1")
        #expect(config.productConfigs[1].id == "com.test.pro2")
    }

    @Test @MainActor func testSimpleProductConfiguration() async throws {
        let config = StoreKitConfiguration()
            .withPurchases(products: [Product("com.test.simple")])

        #expect(config.productConfigs.count == 1)
        #expect(config.productConfigs.first?.id == "com.test.simple")
        #expect(config.productConfigs.first?.features.isEmpty == true)
    }
    
    @Test @MainActor func testPaywallConfiguration() async throws {
        var paywallCalled = false

        let config = StoreKitConfiguration()
            .withPurchases("com.test.pro")
            .withPaywall { context in
                paywallCalled = true
                return Text("Custom Paywall")
            }

        #expect(config.paywallBuilder != nil)

        // Test paywall builder
        let context = PaywallContext()
        _ = config.paywallBuilder?(context)
        #expect(paywallCalled)
    }

    @MainActor
    @Test func testPaywallContextMarketingHelpers() {
        // Create a context with empty products for testing
        let context = PaywallContext(
            triggeredBy: "test_feature",
            availableProducts: [],
            recommendedProduct: nil
        )

        // Test productsWithMarketing property with empty products
        #expect(context.productsWithMarketing.isEmpty)

        // Test that the context initializes correctly
        #expect(context.triggeredBy == "test_feature")
        #expect(context.availableProducts.isEmpty)
        #expect(context.recommendedProduct == nil)
    }
    
    @Test @MainActor func testTermsAndPrivacyConfiguration() async throws {
        var termsCalled = false
        var privacyCalled = false
        
        let config = StoreKitConfiguration()
            .withPurchases("com.test.pro")
            .withTerms {
                termsCalled = true
                return Text("Custom Terms")
            }
            .withPrivacy {
                privacyCalled = true
                return Text("Custom Privacy")
            }
        
        #expect(config.termsBuilder != nil)
        #expect(config.privacyBuilder != nil)
        
        // Test builders
        _ = config.termsBuilder?()
        _ = config.privacyBuilder?()
        #expect(termsCalled)
        #expect(privacyCalled)
    }
    
    // MARK: - AppFeature Tests
    
    @Test func testAppFeatureProtocol() {
        let syncFeature = TestFeature.sync
        #expect(syncFeature.rawValue == "sync")
    }
    
    @Test @MainActor func testStoreKitManagerAppFeatureExtensions() async {
        let manager = InAppKit.shared
        
        // Register feature
        manager.registerFeature(TestFeature.sync, productIds: ["com.test.pro"])
        
        // Check registration
        #expect(manager.isFeatureRegistered(TestFeature.sync))
        
        // Check access (should be false since no purchase)
        #expect(!manager.hasAccess(to: TestFeature.sync))
    }
    
    // MARK: - Convenience Extensions Tests
    
    @Test func testConvenienceExtensions() {
        let size5MB = 5.mb
        let size10MB = 10.MB
        
        #expect(size5MB == 5 * 1024 * 1024)
        #expect(size10MB == 10 * 1024 * 1024)
    }
    
    
    // MARK: - View Extension Tests
    
    @Test @MainActor func testViewExtensionsCompile() {
        // Test that view extensions compile correctly
        let baseView = Text("Test")
        
        let premiumView = baseView.requiresPurchase()
        let productView = baseView.requiresPurchase("com.test.pro")
        let featureView = baseView.requiresPurchase(TestFeature.sync)
        let conditionalView = baseView.requiresPurchase(when: true)
        
        // These tests mainly verify compilation
        #expect(type(of: premiumView) != type(of: baseView))
        #expect(type(of: productView) != type(of: baseView))
        #expect(type(of: featureView) != type(of: baseView))
        #expect(type(of: conditionalView) != type(of: baseView))
    }
    
    // MARK: - Chained View API Tests
    
    @Test @MainActor func testChainedViewAPI() {
        // Test the chained view API pattern
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
        
        // Test that the chained view is of the correct type
        #expect(type(of: chainedView) == ChainableStoreKitView<Text>.self)
        
        // Verify configuration is properly set
        #expect(chainedView.config.productConfigs.count == 1)
        #expect(chainedView.config.productConfigs.first?.id == "com.test.pro")
        #expect(chainedView.config.paywallBuilder != nil)
        #expect(chainedView.config.termsBuilder != nil)
        #expect(chainedView.config.privacyBuilder != nil)
    }
    
    @Test @MainActor func testProductConvenienceFunctions() {
        // Test the new Product convenience functions
        let product1 = Product("com.test.basic", features: [TestFeature.sync])
        #expect(product1.id == "com.test.basic")
        #expect(product1.features.count == 1)
        
        // Test array syntax with features: label
        let product2 = Product("com.test.pro", features: [TestFeature.sync, TestFeature.export])
        #expect(product2.id == "com.test.pro")
        #expect(product2.features.count == 2)

        // Test .allCases support with features: label
        let product3 = Product("com.test.premium", features: TestFeature.allCases)
        #expect(product3.id == "com.test.premium")
        #expect(product3.features.count == TestFeature.allCases.count)
    }
    
    @Test @MainActor func testSingleProductChain() {
        // Test chaining with single product ID
        let baseView = Text("Test")
        
        let chainedView = baseView
            .withPurchases("com.test.pro")
            .withPaywall { _ in Text("Simple Paywall") }
        
        #expect(type(of: chainedView) == ChainableStoreKitView<Text>.self)
        #expect(chainedView.config.productConfigs.count == 1)
        #expect(chainedView.config.productConfigs.first?.id == "com.test.pro")
    }
    
    @Test @MainActor func testChainedViewAPIWithoutPaywall() {
        // Test that terms and privacy work even without custom paywall
        let baseView = Text("Test Content")
        
        let chainedView = baseView
            .withPurchases(products: [
                Product("com.test.pro", features: [TestFeature.sync])
            ])
            .withTerms {
                Text("Custom Terms")
            }
            .withPrivacy {
                Text("Custom Privacy")
            }
        
        // Test that the configuration includes terms and privacy even without paywall
        #expect(chainedView.config.productConfigs.count == 1)
        #expect(chainedView.config.paywallBuilder == nil) // No custom paywall
        #expect(chainedView.config.termsBuilder != nil) // But terms are configured
        #expect(chainedView.config.privacyBuilder != nil) // And privacy is configured
    }

    // MARK: - TDD: Consistent Product API Tests

    @Test @MainActor func testProductNoFeatures() {
        // Test: Product("id") - no features
        let product = Product("com.test.simple")

        #expect(product.id == "com.test.simple")
        #expect(product.features.isEmpty)
        #expect(type(of: product) == ProductConfig<String>.self)
    }

    @Test @MainActor func testProductWithEnumFeatures() {
        // Test: Product("id", features: [.enum]) - enum features with label
        let product = Product("com.test.basic", features: [TestFeature.sync])

        #expect(product.id == "com.test.basic")
        #expect(product.features.count == 1)
        #expect(product.features.contains(TestFeature.sync))
        #expect(type(of: product) == ProductConfig<TestFeature>.self)
    }

    @Test @MainActor func testProductWithMultipleEnumFeatures() {
        // Test: Product("id", features: [.enum1, .enum2]) - multiple enum features
        let product = Product("com.test.pro", features: [TestFeature.sync, TestFeature.export, TestFeature.premium])

        #expect(product.id == "com.test.pro")
        #expect(product.features.count == 3)
        #expect(product.features.contains(TestFeature.sync))
        #expect(product.features.contains(TestFeature.export))
        #expect(product.features.contains(TestFeature.premium))
    }

    @Test @MainActor func testProductWithAllCases() {
        // Test: Product("id", features: Enum.allCases) - allCases with label
        let product = Product("com.test.premium", features: TestFeature.allCases)

        #expect(product.id == "com.test.premium")
        #expect(product.features.count == TestFeature.allCases.count)
        #expect(product.features.count == 3) // sync, export, premium

        // Verify all cases are included
        for feature in TestFeature.allCases {
            #expect(product.features.contains(feature))
        }
    }

    @Test @MainActor func testProductWithStringFeatures() {
        // Test: Product("id", features: ["string"]) - string features
        let product = Product("com.test.string", features: ["feature1", "feature2"])

        #expect(product.id == "com.test.string")
        #expect(product.features.count == 2)
        #expect(product.features.contains("feature1"))
        #expect(product.features.contains("feature2"))
        #expect(type(of: product) == ProductConfig<String>.self)
    }

    @Test @MainActor func testProductConfiguration() {
        // Test complete configuration with mixed product types
        let config = StoreKitConfiguration()
            .withPurchases(products: [
                Product("com.test.basic", features: [TestFeature.sync, TestFeature.export, TestFeature.premium]),
                Product("com.test.premium", features: TestFeature.allCases),
                Product("com.test.premium1", features: ["some-feature"]),
                Product("com.test.basic1")
            ])

        #expect(config.productConfigs.count == 4)
        #expect(config.productConfigs[0].id == "com.test.basic")
        #expect(config.productConfigs[1].id == "com.test.premium")
        #expect(config.productConfigs[2].id == "com.test.premium1")
        #expect(config.productConfigs[3].id == "com.test.basic1")

        // Features count verification
        #expect(config.productConfigs[0].features.count == 3)
        #expect(config.productConfigs[1].features.count == 3)
        #expect(config.productConfigs[2].features.count == 1)
        #expect(config.productConfigs[3].features.isEmpty)
    }

    @Test @MainActor func testProductWithView() {
        // Test Product with view chaining
        let baseView = Text("Premium Content")

        let premiumView = baseView
            .withPurchases(products: [
                Product("com.test.basic", features: [TestFeature.sync, TestFeature.export, TestFeature.premium])
            ])
            .withPaywall { context in
                Text("Upgrade to Premium")
            }

        #expect(type(of: premiumView) == ChainableStoreKitView<Text>.self)
        #expect(premiumView.config.productConfigs.count == 1)
        #expect(premiumView.config.productConfigs.first?.features.count == 3)
    }
}
