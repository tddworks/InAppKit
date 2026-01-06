# API Reference

> **Complete technical documentation for InAppKit**

## 📖 Table of Contents

- [Architecture Overview](#architecture-overview)
- [Product Functions](#product-functions)
- [Configuration](#configuration)
- [View Modifiers](#view-modifiers)
- [InAppKit Core](#inappkit-core)
- [Domain Models](#domain-models)
- [Types & Protocols](#types--protocols)
- [Testing](#testing)
- [Troubleshooting](#troubleshooting)

## Architecture Overview

InAppKit follows **Domain-Driven Design** with clear separation between domain logic and infrastructure.

```
Sources/InAppKit/
├── Core/
│   ├── Domain/           ← Pure business logic (100% testable)
│   │   ├── ProductDefinition.swift
│   │   ├── DiscountRule.swift
│   │   ├── PurchaseState.swift
│   │   ├── FeatureRegistry.swift
│   │   ├── AccessControl.swift
│   │   ├── MarketingRegistry.swift
│   │   └── Store.swift (protocol)
│   └── InAppKit.swift    ← Main coordinator
├── Infrastructure/       ← StoreKit integration
│   ├── AppStore.swift
│   └── StoreKitProvider.swift
├── Modifiers/           ← SwiftUI integration
│   └── PurchaseSetup.swift
└── UI/                  ← UI components
```

**Key Principles:**
- Domain models are pure, with no StoreKit dependencies
- Infrastructure implements domain protocols
- InAppKit delegates to domain models for business logic

## Product Functions

### Product Creation

All Product functions follow a consistent pattern: *Need features? Use `features:` parameter*

```swift
// No features
public func Product(_ id: String) -> ProductDefinition<String>

// With features array
public func Product<T: Hashable>(_ id: String, features: [T]) -> ProductDefinition<T>

// With allCases (for CaseIterable enums)
public func Product<T: CaseIterable & Hashable>(_ id: String, features: T.AllCases) -> ProductDefinition<T>
```

#### Examples

```swift
// Simple product
Product("com.app.pro")

// Enum features
Product("com.app.pro", features: [MyFeature.sync, MyFeature.export])

// All enum cases
Product("com.app.premium", features: MyFeature.allCases)

// String features
Product("com.app.custom", features: ["feature1", "feature2"])
```

### Marketing Extensions

```swift
extension ProductDefinition {
    func withBadge(_ badge: String) -> ProductDefinition<Feature>
    func withBadge(_ badge: String, color: Color) -> ProductDefinition<Feature>
    func withMarketingFeatures(_ features: [String]) -> ProductDefinition<Feature>
    func withPromoText(_ text: String) -> ProductDefinition<Feature>
    func withRelativeDiscount(
        comparedTo baseProductId: String,
        style: DiscountRule.Style = .percentage,
        color: Color? = nil
    ) -> ProductDefinition<Feature>
}
```

#### Manual Promotional Text Example

```swift
Product("com.app.pro", features: [Feature.sync])
    .withBadge("Most Popular", color: .orange)
    .withMarketingFeatures(["Cloud sync", "Priority support"])
    .withPromoText("Save 30%")
```

#### Automatic Discount Calculation

The `.withRelativeDiscount()` method automatically calculates savings by comparing prices:

```swift
// Automatic percentage discount (default)
Product("com.app.yearly", features: features)
    .withRelativeDiscount(comparedTo: "com.app.monthly")
// Displays: "Save 31%" (calculated automatically from actual prices)

// With custom color
Product("com.app.yearly", features: features)
    .withRelativeDiscount(comparedTo: "com.app.monthly", color: .green)
// Displays: "Save 31%" in green

// Different display styles
Product("com.app.yearly", features: features)
    .withRelativeDiscount(comparedTo: "com.app.monthly", style: .amount)
// Displays: "Save $44" (based on actual price difference)

Product("com.app.yearly", features: features)
    .withRelativeDiscount(comparedTo: "com.app.monthly", style: .freeTime)
// Displays: "2 months free" (calculated from savings)
```

**Discount Styles:**
- `.percentage` - "Save 31%" (default)
- `.amount` - "Save $44"
- `.freeTime` - "2 months free"

**Benefits:**
- ✅ Automatic calculation - no manual math
- ✅ Always accurate - updates with App Store price changes
- ✅ Localized - currency formatting by locale
- ✅ Customizable color - match your brand

## Configuration

### PurchaseSetup

```swift
public class PurchaseSetup {
    public init()

    // Product configuration
    public func withPurchases(_ productId: String) -> PurchaseSetup
    public func withPurchases(_ productIds: String...) -> PurchaseSetup
    public func withPurchases<T: Hashable>(products: [ProductDefinition<T>]) -> PurchaseSetup

    // UI configuration
    public func withPaywall<Content: View>(@ViewBuilder _ builder: @escaping (PaywallContext) -> Content) -> PurchaseSetup
    public func withPaywallHeader<Content: View>(@ViewBuilder _ builder: @escaping () -> Content) -> PurchaseSetup
    public func withPaywallFeatures<Content: View>(@ViewBuilder _ builder: @escaping () -> Content) -> PurchaseSetup
    public func withTerms<Content: View>(@ViewBuilder _ builder: @escaping () -> Content) -> PurchaseSetup
    public func withTerms(url: URL) -> PurchaseSetup
    public func withPrivacy<Content: View>(@ViewBuilder _ builder: @escaping () -> Content) -> PurchaseSetup
    public func withPrivacy(url: URL) -> PurchaseSetup
}
```

#### Example

```swift
let config = PurchaseSetup()
    .withPurchases(products: [
        Product("com.app.basic", features: [Feature.removeAds]),
        Product("com.app.pro", features: Feature.allCases)
    ])
    .withPaywall { context in
        CustomPaywallView(context: context)
    }
    .withTerms {
        TermsOfServiceView()
    }
    .withPrivacy {
        PrivacyPolicyView()
    }
```

## View Modifiers

### Purchase Requirements

```swift
extension View {
    // Require any purchase
    func requiresPurchase() -> some View

    // Require specific product
    func requiresPurchase(_ productId: String) -> some View

    // Require specific feature
    func requiresPurchase<T: AppFeature>(_ feature: T) -> some View

    // Conditional requirement
    func requiresPurchase(when condition: Bool) -> some View

    // With custom paywall
    func requiresPurchase<T: AppFeature, Content: View>(
        _ feature: T,
        @ViewBuilder paywall: @escaping (PaywallContext) -> Content
    ) -> some View
}
```

### Configuration

```swift
extension View {
    // Direct configuration
    func withPurchases(_ productId: String) -> PurchaseEnabledView<Self>
    func withPurchases(_ productIds: String...) -> PurchaseEnabledView<Self>
    func withPurchases<T: Hashable>(products: [ProductDefinition<T>]) -> PurchaseEnabledView<Self>
}
```

### Chained Configuration

```swift
extension PurchaseEnabledView {
    func withPaywall<Content: View>(@ViewBuilder _ builder: @escaping (PaywallContext) -> Content) -> PurchaseEnabledView<Content>
    func withPaywallHeader<Content: View>(@ViewBuilder _ builder: @escaping () -> Content) -> PurchaseEnabledView<Content>
    func withPaywallFeatures<Content: View>(@ViewBuilder _ builder: @escaping () -> Content) -> PurchaseEnabledView<Content>
    func withTerms<Content: View>(@ViewBuilder _ builder: @escaping () -> Content) -> PurchaseEnabledView<Content>
    func withTerms(url: URL) -> PurchaseEnabledView<Content>
    func withPrivacy<Content: View>(@ViewBuilder _ builder: @escaping () -> Content) -> PurchaseEnabledView<Content>
    func withPrivacy(url: URL) -> PurchaseEnabledView<Content>
}
```

#### Example

```swift
ContentView()
    .withPurchases(products: [Product("com.app.pro", features: Feature.allCases)])
    .withPaywall { context in
        PaywallView(context: context)
    }
    .withTerms {
        TermsView()
    }
    .withPrivacy {
        PrivacyView()
    }
```

## InAppKit Core

### Shared Instance

```swift
public class InAppKit: ObservableObject {
    public static let shared = InAppKit()

    // Purchase status
    public func hasAccess(to productId: String) -> Bool
    public func hasAccess<T: AppFeature>(to feature: T) -> Bool
    public func hasAccess(to feature: AnyHashable) -> Bool

    // Product information
    public func products<T: AppFeature>(for feature: T) -> [Product]
    public func products(for feature: AnyHashable) -> [Product]

    // Feature management
    public func registerFeature<T: AppFeature>(_ feature: T, productIds: [String])
    public func registerFeature(_ feature: AnyHashable, productIds: [String])
    public func isFeatureRegistered<T: AppFeature>(_ feature: T) -> Bool

    // Marketing information
    public func badge(for productId: String) -> String?
    public func marketingFeatures(for productId: String) -> [String]?
    public func savings(for productId: String) -> String?

    // Purchase actions
    public func purchase(_ product: Product) async -> Bool
    public func restorePurchases() async -> Bool
}
```

#### Examples

```swift
// Check access
if InAppKit.shared.hasAccess(to: Feature.cloudSync) {
    syncToCloud()
}

// Get products for feature
let products = InAppKit.shared.products(for: Feature.exportPDF)

// Purchase product
Task {
    let success = await InAppKit.shared.purchase(product)
    if success {
        // Handle successful purchase
    }
}

// Restore purchases
Task {
    await InAppKit.shared.restorePurchases()
}
```

## Types & Protocols

### AppFeature Protocol

```swift
public protocol AppFeature: Hashable, CaseIterable {
    var rawValue: String { get }
}
```

#### Implementation

```swift
enum MyAppFeature: String, AppFeature {
    case removeAds = "remove_ads"
    case cloudSync = "cloud_sync"
    case exportPDF = "export_pdf"
}
```

### ProductDefinition

```swift
public struct ProductDefinition<Feature: Hashable>: AnyProductDefinition {
    public let id: String
    public let features: [Feature]
    public let badge: String?
    public let badgeColor: Color?
    public let marketingFeatures: [String]?
    public let promoText: String?
    public let discountRule: DiscountRule?

    public init(
        _ id: String,
        features: [Feature],
        badge: String? = nil,
        badgeColor: Color? = nil,
        marketingFeatures: [String]? = nil,
        promoText: String? = nil,
        discountRule: DiscountRule? = nil
    )
}
```

### DiscountRule

```swift
public struct DiscountRule: Sendable {
    public let comparedTo: String  // base product ID
    public let style: Style
    public let color: Color?

    public init(comparedTo baseProductId: String, style: Style = .percentage, color: Color? = nil)

    public enum Style: Sendable {
        case percentage  // "31% off"
        case amount      // "Save $44"
        case freeTime    // "2 months free"
    }
}
```

### PaywallContext

```swift
public struct PaywallContext {
    public let triggeredBy: String?
    public let availableProducts: [Product]
    public let recommendedProduct: Product?

    // Marketing helpers
    @MainActor public func badge(for product: Product) -> String?
    @MainActor public func marketingFeatures(for product: Product) -> [String]?
    @MainActor public func promoText(for product: Product) -> String?
    @MainActor public func marketingInfo(for product: Product) -> (badge: String?, features: [String]?, promoText: String?)
    @MainActor public var productsWithMarketing: [(product: Product, badge: String?, features: [String]?, promoText: String?)]
}
```

### PurchaseEnabledView

```swift
public struct PurchaseEnabledView<Content: View>: View {
    let content: Content
    let config: PurchaseSetup

    public var body: some View
}
```

## Domain Models

Pure domain models with no StoreKit dependencies. 100% testable without mocks.

### PurchaseState

Immutable value type tracking what the user has purchased.

```swift
public struct PurchaseState: Equatable, Sendable {
    public private(set) var purchasedProductIDs: Set<String>

    public var hasAnyPurchase: Bool
    public func isPurchased(_ productId: String) -> Bool

    // Immutable updates
    public func withPurchase(_ productId: String) -> PurchaseState
    public func withoutPurchase(_ productId: String) -> PurchaseState
    public func cleared() -> PurchaseState
}
```

### FeatureRegistry

Maps features to products that unlock them.

```swift
public struct FeatureRegistry: Equatable {
    public func isRegistered(_ feature: AnyHashable) -> Bool
    public func productIds(for feature: AnyHashable) -> Set<String>
    public func features(unlockedBy productId: String) -> Set<AnyHashable>

    // Immutable updates
    public func withFeature(_ feature: AnyHashable, productIds: [String]) -> FeatureRegistry
    public func withoutFeature(_ feature: AnyHashable) -> FeatureRegistry
}
```

### AccessControl

Pure functions for access control decisions.

```swift
public enum AccessControl {
    public static func hasAccess(
        to feature: AnyHashable,
        purchaseState: PurchaseState,
        featureRegistry: FeatureRegistry
    ) -> Bool

    public static func accessibleFeatures(
        purchaseState: PurchaseState,
        featureRegistry: FeatureRegistry
    ) -> Set<AnyHashable>
}
```

### MarketingRegistry

Stores marketing information for products.

```swift
public struct MarketingRegistry {
    public func badge(for productId: String) -> String?
    public func badgeColor(for productId: String) -> Color?
    public func features(for productId: String) -> [String]?
    public func promoText(for productId: String) -> String?
    public func relativeDiscountConfig(for productId: String) -> DiscountRule?

    // Immutable updates
    public func withMarketing(_ productId: String, marketing: ProductMarketing) -> MarketingRegistry
    public func withMarketing(from config: InternalProductConfig) -> MarketingRegistry
}
```

### Store Protocol

Protocol for store operations (implements `@Mockable` for testing).

```swift
@Mockable
public protocol Store: Sendable {
    func products(for ids: Set<String>) async throws -> [Product]
    func purchase(_ product: Product) async throws -> PurchaseOutcome
    func purchases() async throws -> Set<String>
    func restore() async throws -> Set<String>
}

public enum PurchaseOutcome: Sendable {
    case success
    case cancelled
    case pending
}
```

## Testing

### Domain Tests (Pure, No Mocks)

Domain models are fully testable without mocks:

```swift
@Test func `user with correct purchase has access to feature`() {
    // Given
    let purchaseState = PurchaseState(purchasedProductIDs: ["com.app.pro"])
    let registry = FeatureRegistry().withFeature("sync", productIds: ["com.app.pro"])

    // When
    let hasAccess = AccessControl.hasAccess(
        to: "sync",
        purchaseState: purchaseState,
        featureRegistry: registry
    )

    // Then
    #expect(hasAccess)
}
```

### Infrastructure Tests (With Mockable)

Infrastructure tests use auto-generated mocks:

```swift
@Test func `loadProducts calls store`() async {
    // Given
    let mockStore = MockStore()
    given(mockStore).products(for: .any).willReturn([])

    let inAppKit = InAppKit.configure(with: mockStore)

    // When
    await inAppKit.loadProducts(productIds: ["com.app.pro"])

    // Then
    await verify(mockStore).products(for: .value(Set(["com.app.pro"]))).called(.once)
}
```

### Debug Helpers

```swift
#if DEBUG
// Simulate purchases for testing
InAppKit.shared.simulatePurchase("com.app.pro")

// Clear purchases
InAppKit.shared.clearPurchases()

// Clear registries
InAppKit.shared.clearFeatures()
InAppKit.shared.clearMarketing()
#endif
```

## Troubleshooting

### Common Issues

#### 1. Features Not Working

**Problem**: `requiresPurchase()` not showing paywall

**Solutions**:
```swift
// ✅ Ensure product is configured
ContentView()
    .withPurchases("com.app.pro")  // Must be configured first

// ✅ Check feature is registered
InAppKit.shared.registerFeature(Feature.cloudSync, productIds: ["com.app.pro"])

// ✅ Verify product ID matches App Store Connect
Product("com.yourapp.pro")  // Must match exactly
```

#### 2. Type Errors

**Problem**: `Cannot convert value of type...`

**Solutions**:
```swift
// ❌ Wrong: Mixed types
Product("com.app.pro", features: [MyFeature.sync, "string_feature"])

// ✅ Correct: Consistent types
Product("com.app.pro", features: [MyFeature.sync, MyFeature.export])
Product("com.app.custom", features: ["feature1", "feature2"])
```

#### 3. Missing features: Parameter

**Problem**: `Missing argument label 'features:' in call`

**Solutions**:
```swift
// ❌ Wrong: Old syntax removed
Product("com.app.pro", [Feature.sync])

// ✅ Correct: Always use features: label
Product("com.app.pro", features: [Feature.sync])
Product("com.app.premium", features: Feature.allCases)
```

#### 4. Paywall Not Showing

**Problem**: Paywall doesn't appear when expected

**Solutions**:
```swift
// ✅ Check purchase status
if !InAppKit.shared.hasAccess(to: Feature.cloudSync) {
    // Paywall should show
}

// ✅ Verify paywall configuration
ContentView()
    .withPurchases(products: [...])
    .withPaywall { context in  // Must be configured
        PaywallView(context: context)
    }

// ✅ Use explicit paywall
Text("Premium Content")
    .requiresPurchase(Feature.premium) { context in
        CustomPaywallView(context: context)
    }
```

### Debugging

#### Enable Debug Logging

```swift
#if DEBUG
// Add this to see InAppKit internal state
UserDefaults.standard.set(true, forKey: "InAppKitDebugMode")
#endif
```

#### Test Purchases

```swift
#if DEBUG
// Simulate purchases for testing
UserDefaults.standard.set(true, forKey: "purchased_com.app.pro")

// Or use StoreKit configuration files
// See Apple's StoreKit Testing documentation
#endif
```

#### Verify Configuration

```swift
struct DebugView: View {
    var body: some View {
        VStack {
            Text("Registered Products:")
            ForEach(InAppKit.shared.registeredProducts, id: \\.self) { productId in
                Text(productId)
            }

            Text("Has Access:")
            Text("Pro: \\(InAppKit.shared.hasAccess(to: "com.app.pro"))")
            Text("Feature: \\(InAppKit.shared.hasAccess(to: Feature.cloudSync))")
        }
    }
}
```

### Performance

#### Best Practices

```swift
// ✅ Configure once at app level
ContentView()
    .withPurchases(products: products)  // Configure here

// ✅ Check access in view models
class ViewModel: ObservableObject {
    @Published var hasProAccess = false

    init() {
        hasProAccess = InAppKit.shared.hasAccess(to: Feature.pro)
    }
}

// ✅ Cache feature checks for lists
struct ItemList: View {
    let hasAdvancedFeatures = InAppKit.shared.hasAccess(to: Feature.advanced)

    var body: some View {
        ForEach(items) { item in
            ItemRow(item: item, showAdvanced: hasAdvancedFeatures)
        }
    }
}
```

---

**Need more help?**
- [GitHub Issues](https://github.com/tddworks/InAppKit/issues) - Bug reports and feature requests
- [GitHub Discussions](https://github.com/tddworks/InAppKit/discussions) - Community support
- [Getting Started Guide](getting-started.md) - Learn the basics
- [Customization Guide](customization.md) - UI and advanced features