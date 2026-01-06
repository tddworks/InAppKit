# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Building and Testing
- **Build**: `swift build`
- **Test**: `swift test`
- **Single test**: Use test explorer in Xcode or target specific test methods in Swift Testing
- **Swift version**: `swift --version` (requires Swift 6.2+)

### Xcode Development
- Open `InAppKit.xcodeproj` or `Workspace.xcworkspace` for full IDE experience
- Project supports iOS 17+, macOS 15+, watchOS 10+, tvOS 17+

## Architecture Overview

InAppKit is a SwiftUI library that simplifies in-app purchases through a declarative API. The architecture follows **Domain-Driven Design** with clear separation between domain logic and infrastructure.

### Domain Layer (`Sources/InAppKit/Core/Domain/`)

Pure business logic with 100% test coverage. No StoreKit dependencies.

| Model | Purpose |
|-------|---------|
| `ProductDefinition` | Define products to sell with features and marketing |
| `DiscountRule` | Configure relative discounts between products |
| `PaywallContext` | Context data for paywall presentation |
| `PurchaseState` | Immutable purchase state (what user owns) |
| `FeatureRegistry` | Feature-to-product mappings |
| `AccessControl` | Pure functions for access control decisions |
| `MarketingRegistry` | Product marketing information storage |
| `Store` | Protocol for store operations (@Mockable) |

### Infrastructure Layer (`Sources/InAppKit/Infrastructure/`)

StoreKit integration. Implements domain protocols.

| Class | Purpose |
|-------|---------|
| `AppStore` | Real Store implementation using StoreKit |
| `StoreKitProvider` | Protocol wrapping StoreKit static methods (@Mockable) |
| `DefaultStoreKitProvider` | Real StoreKit API calls |

### Core Layer (`Sources/InAppKit/Core/`)

| Class | Purpose |
|-------|---------|
| `InAppKit` | Main coordinator, delegates to domain models |
| `Feature` | AppFeature protocol for type-safe features |

### UI Layer (`Sources/InAppKit/UI/`, `Sources/InAppKit/Modifiers/`)

SwiftUI views and modifiers for purchase integration.

## Key Design Patterns

### 1. Domain-Driven Design
- Pure domain models with no external dependencies
- Immutable value types with functional updates
- Business logic encapsulated in domain layer

### 2. Dependency Injection with Mockable
```swift
// Domain protocol
@Mockable
public protocol Store: Sendable {
    func products(for ids: Set<String>) async throws -> [Product]
    func purchase(_ product: Product) async throws -> PurchaseOutcome
    func purchases() async throws -> Set<String>
}

// Production uses real AppStore
let inAppKit = InAppKit.shared  // uses AppStore internally

// Testing uses MockStore (auto-generated)
let mockStore = MockStore()
given(mockStore).purchases().willReturn(["com.app.pro"])
let inAppKit = InAppKit.configure(with: mockStore)
```

### 3. Fluent Configuration API
```swift
ContentView()
    .withPurchases(products: [
        Product("com.app.pro", features: AppFeature.allCases)
            .withBadge("Best Value")
            .withRelativeDiscount(comparedTo: "monthly")
    ])
    .withPaywall { context in PaywallView(products: context.availableProducts) }
```

### 4. View Modifiers
- `.withPurchases()` - Initialize purchase system
- `.requiresPurchase()` - Gate content behind purchases
- `.withPaywall()` - Custom paywall presentation

## Testing Approach

### Domain Tests (100% coverage)
Pure domain models are fully testable without mocks:
```swift
@Test func `user with correct purchase has access to feature`() {
    let purchaseState = PurchaseState(purchasedProductIDs: ["com.app.pro"])
    let registry = FeatureRegistry().withFeature("sync", productIds: ["com.app.pro"])

    let hasAccess = AccessControl.hasAccess(to: "sync", purchaseState: purchaseState, featureRegistry: registry)

    #expect(hasAccess)
}
```

### Infrastructure Tests (with Mockable)
```swift
@Test func `loadProducts calls store products`() async {
    let mockStore = MockStore()
    given(mockStore).products(for: .any).willReturn([])

    let inAppKit = InAppKit.configure(with: mockStore)
    await inAppKit.loadProducts(productIds: ["com.app.pro"])

    await verify(mockStore).products(for: .value(Set(["com.app.pro"]))).called(.once)
}
```

### Test Organization
```
Tests/InAppKitTests/
├── Domain/                    ← Pure domain model tests
│   ├── PurchaseStateTests.swift
│   ├── FeatureRegistryTests.swift
│   ├── AccessControlTests.swift
│   └── MarketingRegistryTests.swift
├── Infrastructure/            ← Tests with MockStore/MockStoreKitProvider
│   ├── StoreTests.swift
│   └── AppStoreTests.swift
└── InAppKitTests.swift        ← Integration tests
```

## Documentation Structure

The project includes comprehensive documentation in the `docs/` directory:

- **[docs/getting-started.md](docs/getting-started.md)** - Core concepts, basic setup, and first integration
- **[docs/api-reference.md](docs/api-reference.md)** - Complete API documentation with all classes and methods
- **[docs/customization.md](docs/customization.md)** - UI customization, theming, and advanced configuration
- **[docs/localization-keys.md](docs/localization-keys.md)** - Internationalization keys and localization setup
- **[docs/monetization-patterns.md](docs/monetization-patterns.md)** - Business strategies and monetization approaches
- **[docs/README.md](docs/README.md)** - Documentation index and navigation

When helping users with InAppKit:
1. Reference these docs for detailed explanations of concepts and patterns
2. Point users to relevant documentation sections for deeper learning
3. Use the API reference for accurate method signatures and usage examples
4. Consult monetization patterns when discussing business strategy
5. Reference localization guide for internationalization questions
