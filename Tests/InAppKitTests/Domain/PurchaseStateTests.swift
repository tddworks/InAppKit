import Testing
@testable import InAppKit

@Suite
struct PurchaseStateTests {

    // MARK: - Creating Purchase State

    @Test
    func `empty purchase state has no purchases`() {
        // Given
        let state = PurchaseState()

        // Then
        #expect(state.purchasedProductIDs.isEmpty)
        #expect(!state.hasAnyPurchase)
    }

    @Test
    func `purchase state can be created with initial purchases`() {
        // Given
        let productIds: Set<String> = ["com.app.pro", "com.app.premium"]

        // When
        let state = PurchaseState(purchasedProductIDs: productIds)

        // Then
        #expect(state.purchasedProductIDs.count == 2)
        #expect(state.hasAnyPurchase)
    }

    // MARK: - Checking Purchases

    @Test
    func `isPurchased returns true for owned product`() {
        // Given
        let state = PurchaseState(purchasedProductIDs: ["com.app.pro"])

        // Then
        #expect(state.isPurchased("com.app.pro"))
    }

    @Test
    func `isPurchased returns false for unowned product`() {
        // Given
        let state = PurchaseState(purchasedProductIDs: ["com.app.pro"])

        // Then
        #expect(!state.isPurchased("com.app.premium"))
    }

    @Test
    func `hasAnyPurchase is true with at least one purchase`() {
        // Given
        let state = PurchaseState(purchasedProductIDs: ["com.app.basic"])

        // Then
        #expect(state.hasAnyPurchase)
    }

    // MARK: - Adding Purchases (Immutable)

    @Test
    func `withPurchase adds a new product and returns new state`() {
        // Given
        let originalState = PurchaseState()

        // When
        let newState = originalState.withPurchase("com.app.pro")

        // Then
        #expect(!originalState.hasAnyPurchase) // Original unchanged
        #expect(newState.isPurchased("com.app.pro"))
        #expect(newState.hasAnyPurchase)
    }

    @Test
    func `withPurchases adds multiple products`() {
        // Given
        let originalState = PurchaseState(purchasedProductIDs: ["com.app.basic"])

        // When
        let newState = originalState.withPurchases(["com.app.pro", "com.app.premium"])

        // Then
        #expect(newState.purchasedProductIDs.count == 3)
        #expect(newState.isPurchased("com.app.basic"))
        #expect(newState.isPurchased("com.app.pro"))
        #expect(newState.isPurchased("com.app.premium"))
    }

    // MARK: - Removing Purchases (Immutable)

    @Test
    func `withoutPurchase removes a product`() {
        // Given
        let state = PurchaseState(purchasedProductIDs: ["com.app.pro", "com.app.premium"])

        // When
        let newState = state.withoutPurchase("com.app.pro")

        // Then
        #expect(!newState.isPurchased("com.app.pro"))
        #expect(newState.isPurchased("com.app.premium"))
    }

    @Test
    func `cleared removes all purchases`() {
        // Given
        let state = PurchaseState(purchasedProductIDs: ["com.app.pro", "com.app.premium"])

        // When
        let newState = state.cleared()

        // Then
        #expect(newState.purchasedProductIDs.isEmpty)
        #expect(!newState.hasAnyPurchase)
    }

    // MARK: - Equality

    @Test
    func `states with same purchases are equal`() {
        // Given
        let state1 = PurchaseState(purchasedProductIDs: ["com.app.pro"])
        let state2 = PurchaseState(purchasedProductIDs: ["com.app.pro"])

        // Then
        #expect(state1 == state2)
    }

    @Test
    func `states with different purchases are not equal`() {
        // Given
        let state1 = PurchaseState(purchasedProductIDs: ["com.app.pro"])
        let state2 = PurchaseState(purchasedProductIDs: ["com.app.premium"])

        // Then
        #expect(state1 != state2)
    }
}
