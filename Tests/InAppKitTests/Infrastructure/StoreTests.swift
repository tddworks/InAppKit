import Testing
import StoreKit
import Mockable
@testable import InAppKit

@Suite
struct StoreTests {

    // MARK: - InAppKit with MockStore

    @Test @MainActor
    func `InAppKit can be created with mock store`() async {
        // Given
        let mockStore = MockStore()

        // Configure mock to return empty purchases
        given(mockStore)
            .purchases()
            .willReturn(Set<String>())

        // When
        let inAppKit = InAppKit.configure(with: mockStore)

        // Then - InAppKit created successfully
        #expect(inAppKit.purchasedProductIDs.isEmpty)
    }

    @Test @MainActor
    func `loadProducts calls store products`() async {
        // Given
        let mockStore = MockStore()

        given(mockStore)
            .purchases()
            .willReturn(Set<String>())

        given(mockStore)
            .products(for: .any)
            .willReturn([])

        let inAppKit = InAppKit.configure(with: mockStore)

        // When
        await inAppKit.loadProducts(productIds: ["com.app.pro"])

        // Then
        await verify(mockStore)
            .products(for: .value(Set(["com.app.pro"])))
            .called(.atLeastOnce)
    }

    @Test @MainActor
    func `restorePurchases calls store restore`() async {
        // Given
        let mockStore = MockStore()

        given(mockStore)
            .purchases()
            .willReturn(Set<String>())

        given(mockStore)
            .restore()
            .willReturn(Set(["com.app.pro"]))

        let inAppKit = InAppKit.configure(with: mockStore)

        // When
        await inAppKit.restorePurchases()

        // Then
        #expect(inAppKit.isPurchased("com.app.pro"))
        await verify(mockStore)
            .restore()
            .called(.once)
    }

    @Test @MainActor
    func `hasAccess returns true after store returns purchases`() async {
        // Given
        let mockStore = MockStore()

        given(mockStore)
            .purchases()
            .willReturn(Set(["com.app.pro"]))

        let inAppKit = InAppKit.configure(with: mockStore)
        inAppKit.registerFeature("premium", productIds: ["com.app.pro"])

        // Wait for initial purchase refresh
        try? await Task.sleep(for: .milliseconds(100))

        // Then
        #expect(inAppKit.hasAccess(to: "premium"))
    }

    @Test @MainActor
    func `hasAccess returns false when store returns no purchases`() async {
        // Given
        let mockStore = MockStore()

        given(mockStore)
            .purchases()
            .willReturn(Set<String>())

        let inAppKit = InAppKit.configure(with: mockStore)
        inAppKit.registerFeature("premium", productIds: ["com.app.pro"])

        // Wait for initial purchase refresh
        try? await Task.sleep(for: .milliseconds(100))

        // Then
        #expect(!inAppKit.hasAccess(to: "premium"))
    }
}

// MARK: - Store Protocol Tests

@Suite
struct StoreProtocolTests {

    @Test
    func `PurchaseOutcome success is equatable`() {
        // Given
        let outcome1 = PurchaseOutcome.success(productId: "com.app.pro")
        let outcome2 = PurchaseOutcome.success(productId: "com.app.pro")
        let outcome3 = PurchaseOutcome.success(productId: "com.app.premium")

        // Then
        #expect(outcome1 == outcome2)
        #expect(outcome1 != outcome3)
    }

    @Test
    func `PurchaseOutcome cancelled is equatable`() {
        #expect(PurchaseOutcome.cancelled == PurchaseOutcome.cancelled)
        #expect(PurchaseOutcome.cancelled != PurchaseOutcome.pending)
    }

    @Test
    func `PurchaseOutcome pending is equatable`() {
        #expect(PurchaseOutcome.pending == PurchaseOutcome.pending)
        #expect(PurchaseOutcome.pending != PurchaseOutcome.cancelled)
    }
}
