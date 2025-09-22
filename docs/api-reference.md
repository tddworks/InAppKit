# API Reference

> **Complete technical documentation for InAppKit**

## 📖 Table of Contents

- [Product Functions](#product-functions)
- [Configuration](#configuration)
- [View Modifiers](#view-modifiers)
- [InAppKit Core](#inappkit-core)
- [Types & Protocols](#types--protocols)
- [Troubleshooting](#troubleshooting)

## Product Functions

### Product Creation

All Product functions follow a consistent pattern: *Need features? Use `features:` parameter*

```swift
// No features
public func Product(_ id: String) -> ProductConfig<String>

// With features array
public func Product<T: Hashable & Sendable>(_ id: String, features: [T]) -> ProductConfig<T>

// With allCases (for CaseIterable enums)
public func Product<T: CaseIterable & Hashable & Sendable>(_ id: String, features: T.AllCases) -> ProductConfig<T>
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
extension ProductConfig {
    func withBadge(_ badge: String) -> ProductConfig<T>
    func withMarketingFeatures(_ features: [String]) -> ProductConfig<T>
    func withSavings(_ savings: String) -> ProductConfig<T>
}
```

#### Example

```swift
Product("com.app.pro", features: [Feature.sync])
    .withBadge("Most Popular")
    .withMarketingFeatures(["Cloud sync", "Priority support"])
    .withSavings("Save 30%")
```

## Configuration

### StoreKitConfiguration

```swift
public class StoreKitConfiguration {
    public init()

    // Product configuration
    public func withPurchases(_ productId: String) -> StoreKitConfiguration
    public func withPurchases(_ productIds: String...) -> StoreKitConfiguration
    public func withPurchases<T: Hashable & Sendable>(products: [ProductConfig<T>]) -> StoreKitConfiguration

    // UI configuration
    public func withPaywall<Content: View>(@ViewBuilder _ builder: @escaping (PaywallContext) -> Content) -> StoreKitConfiguration
    public func withTerms<Content: View>(@ViewBuilder _ builder: @escaping () -> Content) -> StoreKitConfiguration
    public func withPrivacy<Content: View>(@ViewBuilder _ builder: @escaping () -> Content) -> StoreKitConfiguration
}
```

#### Example

```swift
let config = StoreKitConfiguration()
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
    func withPurchases(_ productId: String) -> ChainableStoreKitView<Self>
    func withPurchases(_ productIds: String...) -> ChainableStoreKitView<Self>
    func withPurchases<T: Hashable & Sendable>(products: [ProductConfig<T>]) -> ChainableStoreKitView<Self>

    // Full configuration
    func withConfiguration(_ config: StoreKitConfiguration) -> some View
}
```

### Chained Configuration

```swift
extension ChainableStoreKitView {
    func withPaywall<Content: View>(@ViewBuilder _ builder: @escaping (PaywallContext) -> Content) -> ChainableStoreKitView<WrappedView>
    func withTerms<Content: View>(@ViewBuilder _ builder: @escaping () -> Content) -> ChainableStoreKitView<WrappedView>
    func withPrivacy<Content: View>(@ViewBuilder _ builder: @escaping () -> Content) -> ChainableStoreKitView<WrappedView>
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

### ProductConfig

```swift
public struct ProductConfig<T: Hashable & Sendable>: Sendable {
    public let id: String
    public let features: [T]
    public let badge: String?
    public let marketingFeatures: [String]?
    public let savings: String?

    public init(
        _ id: String,
        features: [T],
        badge: String? = nil,
        marketingFeatures: [String]? = nil,
        savings: String? = nil
    )
}
```

### PaywallContext

```swift
public struct PaywallContext {
    public let triggeredBy: String?
    public let availableProducts: [StoreKit.Product]
    public let recommendedProduct: StoreKit.Product?

    // Marketing helpers
    @MainActor public func badge(for product: StoreKit.Product) -> String?
    @MainActor public func marketingFeatures(for product: StoreKit.Product) -> [String]?
    @MainActor public func savings(for product: StoreKit.Product) -> String?
    @MainActor public func marketingInfo(for product: StoreKit.Product) -> (badge: String?, features: [String]?, savings: String?)
    @MainActor public var productsWithMarketing: [(product: StoreKit.Product, badge: String?, features: [String]?, savings: String?)]
}
```

### ChainableStoreKitView

```swift
public struct ChainableStoreKitView<WrappedView: View>: View {
    public let wrappedView: WrappedView
    public let config: StoreKitConfiguration

    public var body: some View
}
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