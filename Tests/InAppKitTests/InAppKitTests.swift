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
        
        // Test array syntax
        let product2 = Product("com.test.pro", [TestFeature.sync, TestFeature.export])
        #expect(product2.id == "com.test.pro")
        #expect(product2.features.count == 2)
        
        // Test .allCases support (would work with a CaseIterable enum)
        let product3 = Product("com.test.premium", TestFeature.allCases)
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
}
