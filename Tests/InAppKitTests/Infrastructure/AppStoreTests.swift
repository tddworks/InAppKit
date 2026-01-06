import Testing
import StoreKit
import Mockable
@testable import InAppKit

@Suite
struct AppStoreTests {

    // MARK: - Products

    @Test
    func `products fetches from provider`() async throws {
        // Given
        let mockProvider = MockStoreKitProvider()

        given(mockProvider)
            .fetchProducts(for: .any)
            .willReturn([])

        let appStore = AppStore(provider: mockProvider)

        // When
        let products = try await appStore.products(for: ["com.app.pro"])

        // Then
        await verify(mockProvider)
            .fetchProducts(for: .value(Set(["com.app.pro"])))
            .called(.once)

        #expect(products.isEmpty)
    }

    @Test
    func `products throws when provider throws`() async {
        // Given
        let mockProvider = MockStoreKitProvider()

        given(mockProvider)
            .fetchProducts(for: .any)
            .willThrow(StoreError.networkError(NSError(domain: "test", code: -1)))

        let appStore = AppStore(provider: mockProvider)

        // When/Then
        do {
            _ = try await appStore.products(for: ["com.app.pro"])
            Issue.record("Expected error to be thrown")
        } catch {
            // Expected
        }
    }

    // MARK: - Purchases (Entitlements)

    @Test
    func `purchases returns empty when no entitlements`() async throws {
        // Given
        let mockProvider = MockStoreKitProvider()

        given(mockProvider)
            .currentEntitlements()
            .willReturn([])

        let appStore = AppStore(provider: mockProvider)

        // When
        let purchases = try await appStore.purchases()

        // Then
        #expect(purchases.isEmpty)
    }

    // MARK: - Restore

    @Test
    func `restore calls sync then fetches entitlements`() async throws {
        // Given
        let mockProvider = MockStoreKitProvider()

        given(mockProvider)
            .sync()
            .willReturn(())

        given(mockProvider)
            .currentEntitlements()
            .willReturn([])

        let appStore = AppStore(provider: mockProvider)

        // When
        let restored = try await appStore.restore()

        // Then
        await verify(mockProvider)
            .sync()
            .called(.once)

        await verify(mockProvider)
            .currentEntitlements()
            .called(.once)

        #expect(restored.isEmpty)
    }

    @Test
    func `restore throws when sync fails`() async {
        // Given
        let mockProvider = MockStoreKitProvider()

        given(mockProvider)
            .sync()
            .willThrow(StoreError.networkError(NSError(domain: "test", code: -1)))

        let appStore = AppStore(provider: mockProvider)

        // When/Then
        do {
            _ = try await appStore.restore()
            Issue.record("Expected error to be thrown")
        } catch {
            // Expected - sync failed
        }
    }
}

// MARK: - StoreKitProvider Protocol Tests

@Suite
struct StoreKitProviderTests {

    @Test
    func `DefaultStoreKitProvider can be instantiated`() {
        // Given/When
        let provider = DefaultStoreKitProvider()

        // Then - no crash, provider exists
        #expect(provider != nil)
    }
}
