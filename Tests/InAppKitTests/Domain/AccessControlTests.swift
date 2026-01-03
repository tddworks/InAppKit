import Testing
@testable import InAppKit

// Test feature enum for this file
private enum AccessTestFeature: String, AppFeature, CaseIterable {
    case sync
    case export
    case premium
}

@Suite
struct AccessControlTests {

    // MARK: - Basic Access Checks

    @Test
    func `user with no purchases has no access to registered feature`() {
        // Given
        let purchaseState = PurchaseState()
        let registry = FeatureRegistry()
            .withFeature(AnyHashable("sync"), productIds: ["com.app.pro"])

        // When
        let hasAccess = AccessControl.hasAccess(
            to: AnyHashable("sync"),
            purchaseState: purchaseState,
            featureRegistry: registry
        )

        // Then
        #expect(!hasAccess)
    }

    @Test
    func `user with correct purchase has access to feature`() {
        // Given
        let purchaseState = PurchaseState(purchasedProductIDs: ["com.app.pro"])
        let registry = FeatureRegistry()
            .withFeature(AnyHashable("sync"), productIds: ["com.app.pro"])

        // When
        let hasAccess = AccessControl.hasAccess(
            to: AnyHashable("sync"),
            purchaseState: purchaseState,
            featureRegistry: registry
        )

        // Then
        #expect(hasAccess)
    }

    @Test
    func `user with wrong purchase has no access`() {
        // Given
        let purchaseState = PurchaseState(purchasedProductIDs: ["com.app.basic"])
        let registry = FeatureRegistry()
            .withFeature(AnyHashable("sync"), productIds: ["com.app.pro"])

        // When
        let hasAccess = AccessControl.hasAccess(
            to: AnyHashable("sync"),
            purchaseState: purchaseState,
            featureRegistry: registry
        )

        // Then
        #expect(!hasAccess)
    }

    // MARK: - Multiple Products Per Feature

    @Test
    func `user has access when owning any product for feature`() {
        // Given - sync available in both pro and premium
        let purchaseState = PurchaseState(purchasedProductIDs: ["com.app.premium"])
        let registry = FeatureRegistry()
            .withFeature(AnyHashable("sync"), productIds: ["com.app.pro", "com.app.premium"])

        // When
        let hasAccess = AccessControl.hasAccess(
            to: AnyHashable("sync"),
            purchaseState: purchaseState,
            featureRegistry: registry
        )

        // Then
        #expect(hasAccess)
    }

    // MARK: - Fallback Behavior

    @Test
    func `unregistered feature falls back to hasAnyPurchase when user has no purchases`() {
        // Given
        let purchaseState = PurchaseState()
        let registry = FeatureRegistry() // Empty - feature not registered

        // When
        let hasAccess = AccessControl.hasAccess(
            to: AnyHashable("unregistered"),
            purchaseState: purchaseState,
            featureRegistry: registry
        )

        // Then
        #expect(!hasAccess)
    }

    @Test
    func `unregistered feature falls back to hasAnyPurchase when user has purchases`() {
        // Given
        let purchaseState = PurchaseState(purchasedProductIDs: ["com.app.any"])
        let registry = FeatureRegistry() // Empty - feature not registered

        // When
        let hasAccess = AccessControl.hasAccess(
            to: AnyHashable("unregistered"),
            purchaseState: purchaseState,
            featureRegistry: registry
        )

        // Then
        #expect(hasAccess) // Fallback to hasAnyPurchase
    }

    // MARK: - AppFeature Support

    @Test
    func `hasAccess works with AppFeature enum`() {
        // Given
        let purchaseState = PurchaseState(purchasedProductIDs: ["com.app.pro"])
        let registry = FeatureRegistry()
            .withFeature(AccessTestFeature.sync, productIds: ["com.app.pro"])

        // When
        let hasAccess = AccessControl.hasAccess(
            to: AccessTestFeature.sync,
            purchaseState: purchaseState,
            featureRegistry: registry
        )

        // Then
        #expect(hasAccess)
    }

    // MARK: - Batch Access Checks

    @Test
    func `accessStatus returns status for multiple features`() {
        // Given
        let purchaseState = PurchaseState(purchasedProductIDs: ["com.app.pro"])
        let registry = FeatureRegistry()
            .withFeature(AnyHashable("sync"), productIds: ["com.app.pro"])
            .withFeature(AnyHashable("export"), productIds: ["com.app.pro"])
            .withFeature(AnyHashable("premium"), productIds: ["com.app.premium"])

        // When
        let status = AccessControl.accessStatus(
            for: [AnyHashable("sync"), AnyHashable("export"), AnyHashable("premium")],
            purchaseState: purchaseState,
            featureRegistry: registry
        )

        // Then
        #expect(status[AnyHashable("sync")] == true)
        #expect(status[AnyHashable("export")] == true)
        #expect(status[AnyHashable("premium")] == false)
    }

    // MARK: - Accessible Features

    @Test
    func `accessibleFeatures returns all features user has access to`() {
        // Given
        let purchaseState = PurchaseState(purchasedProductIDs: ["com.app.pro"])
        let registry = FeatureRegistry()
            .withFeature(AnyHashable("sync"), productIds: ["com.app.pro"])
            .withFeature(AnyHashable("export"), productIds: ["com.app.pro"])
            .withFeature(AnyHashable("premium"), productIds: ["com.app.premium"])

        // When
        let accessible = AccessControl.accessibleFeatures(
            purchaseState: purchaseState,
            featureRegistry: registry
        )

        // Then
        #expect(accessible.count == 2)
        #expect(accessible.contains(AnyHashable("sync")))
        #expect(accessible.contains(AnyHashable("export")))
        #expect(!accessible.contains(AnyHashable("premium")))
    }

    // MARK: - Missing Features

    @Test
    func `missingFeatures returns features user lacks`() {
        // Given
        let purchaseState = PurchaseState(purchasedProductIDs: ["com.app.pro"])
        let registry = FeatureRegistry()
            .withFeature(AnyHashable("sync"), productIds: ["com.app.pro"])
            .withFeature(AnyHashable("export"), productIds: ["com.app.pro"])
            .withFeature(AnyHashable("premium"), productIds: ["com.app.premium"])

        // When
        let missing = AccessControl.missingFeatures(
            purchaseState: purchaseState,
            featureRegistry: registry
        )

        // Then
        #expect(missing.count == 1)
        #expect(missing.contains(AnyHashable("premium")))
    }

    @Test
    func `user with all purchases has no missing features`() {
        // Given
        let purchaseState = PurchaseState(purchasedProductIDs: ["com.app.pro", "com.app.premium"])
        let registry = FeatureRegistry()
            .withFeature(AnyHashable("sync"), productIds: ["com.app.pro"])
            .withFeature(AnyHashable("premium"), productIds: ["com.app.premium"])

        // When
        let missing = AccessControl.missingFeatures(
            purchaseState: purchaseState,
            featureRegistry: registry
        )

        // Then
        #expect(missing.isEmpty)
    }
}
