import Testing
@testable import InAppKit

// Test feature enum for this file
private enum DomainTestFeature: String, AppFeature, CaseIterable {
    case sync
    case export
    case premium
}

@Suite
struct FeatureRegistryTests {

    // MARK: - Creating Registry

    @Test
    func `empty registry has no features`() {
        // Given
        let registry = FeatureRegistry()

        // Then
        #expect(registry.allFeatures.isEmpty)
        #expect(registry.allProductIds.isEmpty)
    }

    // MARK: - Registering Features

    @Test
    func `register feature maps to product`() {
        // Given
        let registry = FeatureRegistry()

        // When
        let newRegistry = registry.withFeature(
            AnyHashable("sync"),
            productIds: ["com.app.pro"]
        )

        // Then
        #expect(newRegistry.isRegistered(AnyHashable("sync")))
        #expect(newRegistry.productIds(for: AnyHashable("sync")) == ["com.app.pro"])
    }

    @Test
    func `register feature with multiple products`() {
        // Given
        let registry = FeatureRegistry()

        // When
        let newRegistry = registry.withFeature(
            AnyHashable("sync"),
            productIds: ["com.app.pro", "com.app.premium"]
        )

        // Then
        let productIds = newRegistry.productIds(for: AnyHashable("sync"))
        #expect(productIds.count == 2)
        #expect(productIds.contains("com.app.pro"))
        #expect(productIds.contains("com.app.premium"))
    }

    @Test
    func `register multiple features to same product`() {
        // Given
        let registry = FeatureRegistry()

        // When
        let newRegistry = registry
            .withFeature(AnyHashable("sync"), productIds: ["com.app.pro"])
            .withFeature(AnyHashable("export"), productIds: ["com.app.pro"])
            .withFeature(AnyHashable("premium"), productIds: ["com.app.pro"])

        // Then
        let features = newRegistry.features(for: "com.app.pro")
        #expect(features.count == 3)
        #expect(features.contains(AnyHashable("sync")))
        #expect(features.contains(AnyHashable("export")))
        #expect(features.contains(AnyHashable("premium")))
    }

    // MARK: - Querying Registry

    @Test
    func `isRegistered returns false for unknown feature`() {
        // Given
        let registry = FeatureRegistry()
            .withFeature(AnyHashable("sync"), productIds: ["com.app.pro"])

        // Then
        #expect(!registry.isRegistered(AnyHashable("unknown")))
    }

    @Test
    func `productIds returns empty set for unknown feature`() {
        // Given
        let registry = FeatureRegistry()

        // Then
        #expect(registry.productIds(for: AnyHashable("unknown")).isEmpty)
    }

    @Test
    func `features returns empty set for unknown product`() {
        // Given
        let registry = FeatureRegistry()

        // Then
        #expect(registry.features(for: "com.app.unknown").isEmpty)
    }

    @Test
    func `allFeatures returns all registered features`() {
        // Given
        let registry = FeatureRegistry()
            .withFeature(AnyHashable("sync"), productIds: ["com.app.pro"])
            .withFeature(AnyHashable("export"), productIds: ["com.app.premium"])

        // Then
        #expect(registry.allFeatures.count == 2)
        #expect(registry.allFeatures.contains(AnyHashable("sync")))
        #expect(registry.allFeatures.contains(AnyHashable("export")))
    }

    @Test
    func `allProductIds returns all registered product ids`() {
        // Given
        let registry = FeatureRegistry()
            .withFeature(AnyHashable("sync"), productIds: ["com.app.pro", "com.app.premium"])

        // Then
        #expect(registry.allProductIds.count == 2)
        #expect(registry.allProductIds.contains("com.app.pro"))
        #expect(registry.allProductIds.contains("com.app.premium"))
    }

    // MARK: - AppFeature Convenience

    @Test
    func `register AppFeature enum`() {
        // Given
        let registry = FeatureRegistry()

        // When
        let newRegistry = registry.withFeature(DomainTestFeature.sync, productIds: ["com.app.pro"])

        // Then
        #expect(newRegistry.isRegistered(DomainTestFeature.sync))
        #expect(newRegistry.productIds(for: DomainTestFeature.sync).contains("com.app.pro"))
    }

    @Test
    func `register multiple AppFeature enums`() {
        // Given
        let registry = FeatureRegistry()

        // When
        let newRegistry = registry
            .withFeature(DomainTestFeature.sync, productIds: ["com.app.pro"])
            .withFeature(DomainTestFeature.export, productIds: ["com.app.pro"])
            .withFeature(DomainTestFeature.premium, productIds: ["com.app.premium"])

        // Then
        #expect(newRegistry.isRegistered(DomainTestFeature.sync))
        #expect(newRegistry.isRegistered(DomainTestFeature.export))
        #expect(newRegistry.isRegistered(DomainTestFeature.premium))
    }

    // MARK: - Immutability

    @Test
    func `original registry unchanged after adding feature`() {
        // Given
        let original = FeatureRegistry()

        // When
        let _ = original.withFeature(AnyHashable("sync"), productIds: ["com.app.pro"])

        // Then
        #expect(original.allFeatures.isEmpty) // Original unchanged
    }

    // MARK: - Bulk Registration

    @Test
    func `withFeatures registers multiple mappings`() {
        // Given
        let registry = FeatureRegistry()

        // When
        let newRegistry = registry.withFeatures([
            (feature: AnyHashable("sync"), productIds: ["com.app.pro"]),
            (feature: AnyHashable("export"), productIds: ["com.app.pro", "com.app.premium"]),
            (feature: AnyHashable("premium"), productIds: ["com.app.premium"])
        ])

        // Then
        #expect(newRegistry.allFeatures.count == 3)
        #expect(newRegistry.productIds(for: AnyHashable("export")).count == 2)
    }
}
