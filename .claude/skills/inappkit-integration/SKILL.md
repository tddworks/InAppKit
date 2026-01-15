---
name: inappkit-integration
description: |
  Integrate InAppKit for in-app purchases in iOS/macOS SwiftUI apps. Provides subscription management,
  paywall UI, and purchase gating. Use when: (1) Adding in-app purchases to a SwiftUI app,
  (2) Creating subscription tiers (monthly/yearly/lifetime), (3) Gating features behind purchases,
  (4) Building custom paywall UI, (5) User asks about InAppKit integration or subscription setup.
---

# InAppKit Integration

InAppKit is a SwiftUI framework for in-app purchases with declarative configuration.

## Quick Start

### 1. Add Dependency

**Tuist (Project.swift):**
```swift
packages: [
    .local(path: "/path/to/InAppKit"),
]

// In target dependencies:
.external(name: "InAppKit"),
```

### 2. Create StoreKit Configuration

Create `AppNameStore.storekit` in Resources with products:
- Subscriptions: `com.company.app.pass.monthly`, `com.company.app.pass.yearly`
- Non-consumable: `com.company.app.pass.lifetime`

### 3. Configure App Entry Point

```swift
import SwiftUI
import InAppKit

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .withPurchases(products: [
                    Product(AppConstants.Products.monthly),
                    Product(AppConstants.Products.yearly)
                        .withRelativeDiscount(comparedTo: AppConstants.Products.monthly, style: .percentage)
                        .withBadge("Popular", color: .orange),
                    Product(AppConstants.Products.lifetime)
                ])
                .withPaywallHeader { PaywallHeaderView() }
                .withPaywallFeatures { PaywallFeaturesView() }
                .withTerms(url: AppConstants.URLs.termsOfUse)
                .withPrivacy(url: AppConstants.URLs.privacyPolicy)
        }
    }
}
```

## API Reference

### View Modifiers (Setup)

| Modifier | Purpose |
|----------|---------|
| `.withPurchases(products:)` | Configure products to sell |
| `.withPaywallHeader { }` | Custom paywall header view |
| `.withPaywallFeatures { }` | Custom features list view |
| `.withTerms(url:)` | Terms of service URL |
| `.withPrivacy(url:)` | Privacy policy URL |

### View Modifiers (Gating)

| Modifier | Purpose |
|----------|---------|
| `.requiresPurchase()` | Gate behind any purchase |
| `.requiresPurchase("productId")` | Gate behind specific product |
| `.requiresPurchase(when: condition)` | Conditional gating |
| `.requiresPurchase(whenItemCount: n, exceeds: limit)` | Usage-based gating |

### Product Definition

```swift
Product("com.app.monthly")                    // Basic product
    .withBadge("Popular", color: .orange)     // Add badge
    .withRelativeDiscount(comparedTo: "com.app.monthly", style: .percentage)
    .withMarketingFeatures(["Feature 1", "Feature 2"])
    .withPromoText("Best value!")
```

### InAppKit.shared Properties

| Property | Type | Description |
|----------|------|-------------|
| `hasAnyPurchase` | `Bool` | User has any active purchase |
| `availableProducts` | `[Product]` | Loaded StoreKit products |
| `isPurchasing` | `Bool` | Purchase in progress |
| `purchaseError` | `Error?` | Last purchase error |

### InAppKit.shared Methods

| Method | Description |
|--------|-------------|
| `isPurchased(_ productId:)` | Check specific product |
| `purchase(_ product:)` | Purchase a product |
| `restorePurchases()` | Restore previous purchases |

## Common Patterns

### Subscription Button

```swift
struct SubscriptionButton: View {
    @Binding var presentingPassSheet: Bool
    var isSubscribed: Bool

    var body: some View {
        Button {
            presentingPassSheet = true
        } label: {
            Image(systemName: "crown.fill")
                .foregroundStyle(
                    isSubscribed
                        ? LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom)
                        : LinearGradient(colors: [.gray, .gray.opacity(0.7)], startPoint: .top, endPoint: .bottom)
                )
        }
    }
}

// Usage in toolbar:
ToolbarItem(placement: .primaryAction) {
    SubscriptionButton(
        presentingPassSheet: $presentingPassSheet,
        isSubscribed: InAppKit.shared.hasAnyPurchase
    )
}
.sheet(isPresented: $presentingPassSheet) {
    PaywallView()
}
```

### Feature Gating with Item Limit

```swift
// Limit free users to 3 items
Button("Add Item") { }
    .requiresPurchase(whenItemCount: items.count, exceeds: 3)
```

### Premium Feature Check

```swift
if InAppKit.shared.hasAnyPurchase {
    // Premium feature code
} else {
    // Free tier fallback
}
```

### Custom Paywall Views

**PaywallHeaderView:**
```swift
struct PaywallHeaderView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image("AppIcon")
                .resizable()
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 18))
            Text("App Pro")
                .font(.title.bold())
            Text("Unlock all features")
                .foregroundStyle(.secondary)
        }
    }
}
```

**PaywallFeaturesView:**
```swift
struct PaywallFeaturesView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            FeatureRow(icon: "infinity", title: "Unlimited Items", description: "No limits")
            FeatureRow(icon: "sparkles", title: "Pro Features", description: "Exclusive access")
        }
        .padding()
    }
}

private struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.mint)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.headline)
                Text(description).font(.subheadline).foregroundStyle(.secondary)
            }
        }
    }
}
```

## AppConstants Pattern

```swift
enum AppConstants {
    enum URLs {
        static let privacyPolicy = URL(string: "https://...")!
        static let termsOfUse = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!
    }

    enum Products {
        static let monthly = "com.company.app.pass.monthly"
        static let yearly = "com.company.app.pass.yearly"
        static let lifetime = "com.company.app.pass.lifetime"
    }
}
```

## Checklist

- [ ] Add InAppKit dependency to Project.swift
- [ ] Create StoreKit configuration file with products
- [ ] Add `.withPurchases()` chain to app entry point
- [ ] Create PaywallHeaderView and PaywallFeaturesView
- [ ] Add AppConstants with product IDs and URLs
- [ ] Add SubscriptionButton to main view toolbar
- [ ] Gate premium features with `.requiresPurchase()`
- [ ] Localize paywall feature strings