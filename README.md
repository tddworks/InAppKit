# InAppKit

[![Swift Package Manager](https://img.shields.io/badge/SPM-Compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![Platform](https://img.shields.io/badge/Platform-iOS%2017%2B%20%7C%20macOS%2015%2B%20%7C%20watchOS%2010%2B%20%7C%20tvOS%2017%2B-blue.svg)](https://developer.apple.com/)
[![Swift](https://img.shields.io/badge/Swift-6.1%2B-orange.svg)](https://swift.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Add in-app purchases to your SwiftUI app in minutes, not hours. No StoreKit complexity, just simple code that works.

> 🚀 **InAppKit** - Because in-app purchases shouldn't be complicated.

## 📖 Table of Contents

- [✨ Features](#-features)
- [🚧 Requirements](#-requirements)
- [📦 Installation](#-installation)
- [🚀 Quick Start](#-quick-start)
- [💡 Real-World Examples](#-real-world-examples)
- [📖 Core Concepts](#-core-concepts)
- [🎯 Choose Your App's Monetization Pattern](#-choose-your-apps-monetization-pattern)
- [🔐 Type-Safe Premium Gating](#-type-safe-premium-gating)
- [🎨 Paywall & UI Customization](#-paywall--ui-customization)
- [🏗️ Architecture](#️-architecture)
- [🎯 Advanced Features](#-advanced-features)
- [🛠️ Troubleshooting](#️-troubleshooting)
- [🔒 Privacy & Security](#-privacy--security)
- [🤝 Contributing](#-contributing)
- [📄 License](#-license)

## ✨ What You Get

- **🔗 Simple Setup** - Add `.withPurchases()` to any view and you're done
- **🎯 Smart Gating** - Use `.requiresPurchase()` on any button or view
- **🎨 Beautiful Paywalls** - Professional upgrade screens included
- **⚡ Zero Config** - Works with App Store Connect automatically
- **🔄 Handles Everything** - Purchases, restoration, validation - all automatic
- **📱 Works Everywhere** - iOS, macOS, watchOS, tvOS
- **🎨 Ready-to-Use UI** - Premium badges and upgrade flows included

## 🚧 Requirements

- iOS 17.0+ / macOS 15.0+ / watchOS 10.0+ / tvOS 17.0+
- Xcode 15.0+
- Swift 6.1+

## 📦 Installation

### Swift Package Manager

Add InAppKit to your project using Xcode:

1. Go to **File → Add Package Dependencies**
2. Enter the repository URL: `https://github.com/tddworks/InAppKit.git`
3. Select **Up to Next Major Version** starting from `1.0.0`

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/tddworks/InAppKit.git", from: "1.0.0")
]
```

## 🚀 Quick Start

### 1. Add InAppKit (2 lines)

```swift
ContentView()
    .withPurchases("com.yourapp.pro")
```

*Or with multiple product IDs:*
```swift
ContentView()
    .withPurchases("com.yourapp.pro1", "com.yourapp.pro2")
```

*Or with Product array (simple):*
```swift
ContentView()
    .withPurchases(products: [Product("com.yourapp.pro")])
```

*Or with Product array if you need features:*
```swift
ContentView()
    .withPurchases(products: [Product("com.yourapp.pro", features: [MyFeature.sync, MyFeature.export])])
```

*Or with marketing information for better conversion:*
```swift
ContentView()
    .withPurchases(products: [
        Product("com.yourapp.monthly", features: [MyFeature.sync])
            .withMarketingFeatures(["Cloud sync", "Premium filters"]),

        Product("com.yourapp.annual", features: [MyFeature.sync, MyFeature.export])
            .withBadge("Most Popular")
            .withMarketingFeatures(["Cloud sync", "Premium filters", "Priority support"])
            .withSavings("Save 15%"),

        Product("com.yourapp.lifetime", features: MyFeature.allCases)
            .withBadge("Best Value")
            .withMarketingFeatures(["All features included", "Lifetime updates"])
    ])
```

### 2. Gate any feature (1 line)

```swift
Button("Premium Feature") { doPremiumThing() }
    .requiresPurchase()
```

**That's it!** 🎉 InAppKit handles the rest automatically.

---

### Want More Control?

<details>
<summary>📋 Define specific features</summary>

```swift
enum MyAppFeature: String, AppFeature {
    case removeAds = "remove_ads"
    case cloudSync = "cloud_sync"
    case exportPDF = "export_pdf"
}

ContentView()
    .withPurchases(products: [
        Product("com.yourapp.pro", features: MyAppFeature.allCases)
    ])
```
</details>

<details>
<summary>🎨 Customize the paywall</summary>

```swift
ContentView()
    .withPurchases("com.yourapp.pro")
    .withPaywall { context in
        Text("Unlock \(context.triggeredBy ?? "premium features")")
        // Your custom paywall UI here
    }
```
</details>

<details>
<summary>🎯 Smart conditional upgrades</summary>

```swift
Button("Save Document") { save() }
    .requiresPurchase(AppFeature.cloudSync, when: documentCount > 5)
```
</details>

## 💡 Real-World Examples

### 📸 Photo App: Remove Watermark

```swift
Button("Export Photo") { exportPhoto() }
    .requiresPurchase()
```
*Result: User sees upgrade screen when they try to export*

### ☁️ Note App: Storage Limit

```swift
Button("Save Note") { saveNote() }
    .requiresPurchase(when: noteCount > 50)
```
*Result: After 50 notes, upgrade prompt appears*

### 🎨 Design App: Professional Features

```swift
Button("Export for Client") { exportForClient() }
    .requiresPurchase(AppFeature.clientTools)
```
*Result: Business users see relevant upgrade options*

## 📖 How It Works

### Two Main Concepts

**1. Products** - What users can buy
**2. Features** - What gets unlocked

```swift
// Product: "Pro Version"
// Features: No ads, cloud sync, export
Product("com.app.pro", features: [.noAds, .cloudSync, .export])
```

### Choose Your Monetization Strategy

InAppKit adapts to how your users think about value, not just technical features:

#### 🎯 "Try Before You Buy" (Freemium)
*Perfect for: Apps where users need to experience value first*

```swift
// Users get core functionality, pay for advanced features
Product("com.photoapp.pro", features: [AppFeature.advancedFilters, AppFeature.cloudStorage])
```

**User Mental Model**: *"I love this app, now I want more powerful features"*
- ✅ Users understand the upgrade value
- ✅ Natural conversion from free to paid
- ✅ Low barrier to entry

#### 🏆 "Good, Better, Best" (Tiered Value)
*Perfect for: Different user types with different needs*

```swift
// Starter: Casual users
Product("com.designapp.starter", features: [AppFeature.basicTemplates, AppFeature.export])

// Professional: Power users  
Product("com.designapp.pro", features: [AppFeature.premiumTemplates, AppFeature.advancedExport, AppFeature.teamSharing])

// Enterprise: Teams & organizations
Product("com.designapp.enterprise", features: AppFeature.allCases)
```

**User Mental Model**: *"I know what level of user I am, show me my tier"*
- ✅ Clear value differentiation
- ✅ Room for users to grow
- ✅ Predictable pricing psychology

#### 📦 "Feature Packs" (Bundled Solutions)
*Perfect for: Specialized workflows and use cases*

```swift
// Content Creator Pack
Product("com.videoapp.creator", features: [AppFeature.advancedEditing, AppFeature.exportFormats, AppFeature.musicLibrary])

// Business Pack
Product("com.videoapp.business", features: [AppFeature.branding, AppFeature.analytics, AppFeature.teamWorkspace])
```

**User Mental Model**: *"I need tools for my specific workflow"*
- ✅ Solves complete user problems
- ✅ Higher perceived value
- ✅ Targets specific personas

#### ⏰ "Ongoing Value" (Subscriptions)
*Perfect for: Services that provide continuous value*

```swift
// Monthly: Try it out
Product("com.cloudapp.monthly", features: [AppFeature.cloudSync, AppFeature.prioritySupport])

// Annual: Committed users
Product("com.cloudapp.annual", features: [AppFeature.cloudSync, AppFeature.prioritySupport, AppFeature.advancedFeatures])
```

**User Mental Model**: *"I'm paying for ongoing service and updates"*
- ✅ Matches recurring value delivery
- ✅ Lower monthly commitment
- ✅ Incentivizes annual savings

### API Design Philosophy

InAppKit uses a **fluent chainable API** for clean, readable configuration:

```swift
ContentView()
    .withPurchases(products: [Product("com.app.pro", features: AppFeature.allCases)])
    .withPaywall { context in CustomPaywall(context) }
    .withTerms { TermsView() }
    .withPrivacy { PrivacyView() }
```

## 🎨 Paywall & UI Customization

### Default Paywall

InAppKit includes a beautiful, modern paywall out of the box:

```swift
// Use default paywall with fluent API
ContentView()
    .withPurchases(products: products)
```

### Custom Paywall with Marketing Information

Create your own paywall with full context and marketing information:

```swift
// Enhanced paywall with marketing data from context
ContentView()
    .withPurchases(products: products)
    .withPaywall { context in
        VStack {
            Text("Upgrade to unlock \(context.triggeredBy ?? "premium features")")

            // Simple approach - access marketing info directly
            ForEach(context.availableProducts, id: \.self) { product in
                VStack(alignment: .leading) {
                    HStack {
                        Text(product.displayName)

                        // Badge from context
                        if let badge = context.badge(for: product) {
                            Text(badge)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(4)
                        }

                        Spacer()

                        VStack(alignment: .trailing) {
                            Text(product.displayPrice)

                            // Savings from context
                            if let savings = context.savings(for: product) {
                                Text(savings)
                                    .foregroundColor(.green)
                                    .font(.caption)
                            }
                        }
                    }

                    // Marketing features from context
                    if let features = context.marketingFeatures(for: product) {
                        VStack(alignment: .leading) {
                            ForEach(features, id: \.self) { feature in
                                Text("• \(feature)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    Button("Purchase") {
                        Task {
                            try await InAppKit.shared.purchase(product)
                        }
                    }
                }
                .padding()
                .border(Color.gray)
            }

            // Advanced approach - use productsWithMarketing
            ForEach(context.productsWithMarketing, id: \.product) { item in
                ProductCard(
                    product: item.product,
                    badge: item.badge,
                    features: item.features,
                    savings: item.savings
                )
            }
        }
    }
```

### Enhanced Paywall Context

The `PaywallContext` provides rich information about the paywall trigger and easy access to marketing data:

> **Note**: Marketing information methods are `@MainActor` isolated since they access InAppKit's shared state. This is perfect for SwiftUI views which run on the main actor by default.

```swift
public struct PaywallContext {
    public let triggeredBy: String?        // What action triggered this
    public let availableProducts: [StoreKit.Product] // Products that can be purchased
    public let recommendedProduct: StoreKit.Product?  // Best product recommendation

    // Marketing Information Helpers (Main Actor)
    @MainActor func badge(for product: StoreKit.Product) -> String?
    @MainActor func marketingFeatures(for product: StoreKit.Product) -> [String]?
    @MainActor func savings(for product: StoreKit.Product) -> String?
    @MainActor func marketingInfo(for product: StoreKit.Product) -> (badge: String?, features: [String]?, savings: String?)
    @MainActor var productsWithMarketing: [(product: StoreKit.Product, badge: String?, features: [String]?, savings: String?)]
}
```

### Built-in UI Components

InAppKit provides several built-in UI components:

- **`PaywallView`** - Modern, animated paywall with product selection
- **`PurchaseRequiredBadge`** - Premium crown badge overlay  
- **`TermsPrivacyFooter`** - Configurable footer for terms and privacy
- **`FeatureRow`** - Styled feature list rows
- **`PurchaseOptionCard`** - Purchase option selection cards with dynamic pricing

#### Using UI Components

```swift
// Add premium badge to any view
MyCustomView()
    .withTermsAndPrivacy()

// Use paywall directly
PaywallView()

// Built-in premium badge appears automatically with .requiresPurchase()
```

## 🔐 Type-Safe Premium Gating

### All the Ways to Gate Features

```swift
// Basic - any premium purchase required
.requiresPurchase()

// Specific feature required  
.requiresPurchase(AppFeature.export)

// Only when condition is true
.requiresPurchase(when: fileCount > 10)

// Combine feature + condition
.requiresPurchase(AppFeature.export, when: fileSize > 5.mb)
```

**What happens:** Premium features show a badge, then display your paywall when tapped.

## 🏗️ Under the Hood

### Main Components

**InAppKit.shared** - Handles all the StoreKit complexity
```swift
// Check what user owns
InAppKit.shared.hasAnyPurchase
InAppKit.shared.isPurchased("com.app.pro")

// Manual purchase (usually not needed)
await InAppKit.shared.purchase(product)
```

**Two View Modifiers:**
- `.withPurchases("product-id")` - Set up your products  
- `.requiresPurchase()` - Gate any feature

**Available Variants:**
```swift
// Simple: Just a product ID
.withPurchases("com.app.pro")

// Multiple products: Variadic syntax
.withPurchases("com.app.pro1", "com.app.pro2")

// Advanced: Products with specific features
.withPurchases(products: [Product("com.app.pro", features: AppFeature.allCases)])

// Marketing-enhanced: Boost conversion with badges, features, and savings
.withPurchases(products: [
    Product("com.app.pro", features: AppFeature.allCases)
        .withBadge("Most Popular")
        .withMarketingFeatures(["Cloud sync", "AI features", "Priority support"])
        .withSavings("Save 20%")
])
```

## 🎯 Advanced Features

### 🎨 Marketing-Enhanced Products for Higher Conversion

InAppKit supports rich marketing information to boost conversion rates through badges, feature highlights, and savings displays.

#### **Product API Guidelines**

InAppKit uses a consistent Product API pattern. **Simple rule**: *Need features? Always use `features:` parameter*

**✅ Correct Syntax:**
```swift
// No features
Product("com.app.basic")

// Enum features
Product("com.app.pro", features: [MyFeature.sync, MyFeature.export])

// All enum cases
Product("com.app.premium", features: MyFeature.allCases)

// String features
Product("com.app.custom", features: ["feature1", "feature2"])
```

#### **Configuration Options**

**Option 1: Removed - Use Fluent API Instead**
*The direct configuration with multiple parameters was removed for API consistency*

**Fluent API for Marketing (Recommended)**
```swift
Product("com.app.annual", features: [MyFeature.sync, MyFeature.export])
    .withBadge("Most Popular")
    .withMarketingFeatures(["Cloud sync", "AI features", "Priority support"])
    .withSavings("Save 15%")
```

#### **🚀 Complete Marketing Example**

```swift
ContentView()
    .withPurchases(products: [
        // Monthly Plan
        Product("com.yourapp.monthly", features: [MyFeature.sync])
            .withMarketingFeatures(["Cloud sync", "Basic support"]),

        // Annual Plan (Most Popular)
        Product("com.yourapp.annual", features: [MyFeature.sync, MyFeature.export])
            .withBadge("Most Popular")
            .withMarketingFeatures(["Cloud sync", "Advanced features", "Priority support"])
            .withSavings("Save 30%"),

        // Lifetime Plan
        Product("com.yourapp.lifetime", features: MyFeature.allCases)
            .withBadge("Best Value")
            .withMarketingFeatures(["All features included", "Lifetime updates"])
    ])
```

#### **🎯 Marketing Features**

- **🏷️ Badges**: `"Most Popular"`, `"Best Value"`, `"Limited Time"`, custom text
- **✨ Marketing Features**: User-friendly benefit statements (up to 2 shown as bullet points)
- **💰 Savings**: `"Save 15%"`, `"50% OFF"`, custom savings text
- **🔄 Auto-Trial Detection**: Automatically shows free trial periods from StoreKit

#### **What Users See**

**Before Enhancement:**
```
Pro Annual                    $99.99
Annual subscription           Yearly
```

**After Enhancement:**
```
Pro Annual  [Most Popular]    $99.99
7 days free trial • Annual    Save 30%
• Cloud sync                  Yearly
• Advanced features
```

### Multiple Product Tiers in Practice

```swift
// E-commerce App Example with Marketing Enhancement
ContentView()
    .withPurchases(products: [
        Product("com.shopapp.basic", features: [AppFeature.trackOrders, AppFeature.wishlist])
            .withMarketingFeatures(["Track orders", "Wishlist"]),

        Product("com.shopapp.plus", features: [AppFeature.trackOrders, AppFeature.wishlist, AppFeature.fastShipping])
            .withBadge("Most Popular")
            .withMarketingFeatures(["Fast shipping", "Premium support"])
            .withSavings("Save 25%"),

        Product("com.shopapp.premium", features: AppFeature.allCases)
            .withBadge("Best Value")
            .withMarketingFeatures(["All features", "Priority processing"])
    ])
    .withPaywall { context in
        ShopPaywallView(context: context)
    }

// Productivity App Example  
ContentView()
    .withPurchases(products: [
        Product("com.prodapp.starter", features: [AppFeature.basicProjects]),
        Product("com.prodapp.professional", features: [AppFeature.basicProjects, AppFeature.teamCollaboration, AppFeature.advancedReports]),
        Product("com.prodapp.enterprise", features: AppFeature.allCases)
    ])

// Media App Subscription Tiers
ContentView()
    .withPurchases(products: [
        Product("com.mediaapp.monthly", features: [AppFeature.hdStreaming, AppFeature.downloads]),
        Product("com.mediaapp.annual", features: [AppFeature.hdStreaming, AppFeature.downloads, AppFeature.offlineMode, AppFeature.familySharing])
    ])
```

### Feature Registration

Features are automatically registered when you use the fluent API, but you can also register them manually:

```swift
InAppKit.shared.registerFeature(
    AppFeature.advanced, 
    productIds: ["com.app.pro"]
)
```

### Marketing API Methods

InAppKit provides fluent API methods for enhanced product configuration:

```swift
// Product configuration with marketing
Product("com.app.pro", features: [MyFeature.sync])
    .withBadge("Most Popular")           // Promotional badge
    .withMarketingFeatures([             // User-friendly features (bullet points)
        "Cloud sync across devices",
        "Priority customer support"
    ])
    .withSavings("Save 30%")            // Savings/discount info

// Access marketing data programmatically
let badge = InAppKit.shared.badge(for: "com.app.pro")
let features = InAppKit.shared.marketingFeatures(for: "com.app.pro")
let savings = InAppKit.shared.savings(for: "com.app.pro")
```

### 🎯 Advanced Feature Configuration

InAppKit supports two approaches for defining features, giving you flexibility based on your app's complexity:

#### **Approach 1: Type-Safe AppFeature Protocol (Recommended)**

Define features using the `AppFeature` protocol for type safety and better developer experience:

```swift
import InAppKit

// Define your app's features
enum AppFeature: String, AppFeature, CaseIterable {
    case cloudSync = "cloud_sync"
    case advancedFilters = "advanced_filters"
    case exportPDF = "export_pdf"
    case prioritySupport = "priority_support"
    case teamCollaboration = "team_collaboration"
}

// Configure products with type-safe features
ContentView()
    .withPurchases(products: [
        // Basic Plan
        Product("com.yourapp.basic", features: [AppFeature.cloudSync])
            .withMarketingFeatures(["Cloud sync across devices"]),

        // Pro Plan
        Product("com.yourapp.pro", features: [AppFeature.cloudSync, AppFeature.advancedFilters, AppFeature.exportPDF])
            .withBadge("Most Popular")
            .withMarketingFeatures(["Advanced filters", "PDF export", "Priority support"])
            .withSavings("Save 25%"),

        // Premium Plan
        Product("com.yourapp.premium", features: AppFeature.allCases)
            .withBadge("Best Value")
            .withMarketingFeatures(["All features included", "Team collaboration"])
    ])
```

**Benefits of AppFeature Protocol:**
- ✅ **Type Safety**: Compile-time checks prevent typos
- ✅ **Autocomplete**: IDE provides feature suggestions
- ✅ **Refactoring**: Easy to rename features across codebase
- ✅ **Documentation**: Self-documenting feature names

#### **Approach 2: Flexible Hashable Features**

Use any `Hashable` type for maximum flexibility:

```swift
// Use String literals (simple but less safe)
Product("com.yourapp.pro", features: ["sync", "export", "filters"])

// Use custom types
struct Feature: Hashable {
    let name: String
    let category: String
}

Product("com.yourapp.pro", features: [
    Feature(name: "sync", category: "storage"),
    Feature(name: "export", category: "sharing")
])

// Mix and match different types
Product("com.yourapp.pro", features: ["basic_sync", 42, AppFeature.cloudSync])
```

#### **Feature Usage in UI**

Both approaches work seamlessly with InAppKit's gating system:

```swift
// Type-safe approach (recommended)
Button("Sync to Cloud") { syncToCloud() }
    .requiresPurchase(AppFeature.cloudSync)

Button("Export as PDF") { exportPDF() }
    .requiresPurchase(AppFeature.exportPDF)

// Flexible approach
Button("Advanced Feature") { useAdvancedFeature() }
    .requiresPurchase("advanced_feature")

// Conditional gating
Button("Team Collaboration") { openTeamPanel() }
    .requiresPurchase(AppFeature.teamCollaboration, when: isTeamMember)
```

#### **Runtime Feature Management**

Access and manage features programmatically:

```swift
// Check feature access
if InAppKit.shared.hasAccess(to: AppFeature.cloudSync) {
    enableCloudSync()
}

// Register features manually (usually automatic)
InAppKit.shared.registerFeature(AppFeature.cloudSync, productIds: ["com.app.pro"])

// Check feature registration
if InAppKit.shared.isFeatureRegistered(AppFeature.exportPDF) {
    showExportButton()
}

// Get products that provide a feature
let syncProducts = InAppKit.shared.products(for: AppFeature.cloudSync)
```

#### **Complex Feature Hierarchies**

For apps with complex feature sets, organize features into logical groups:

```swift
enum CreativeFeature: String, AppFeature, CaseIterable {
    // Export Features
    case exportHD = "export_hd"
    case exportRAW = "export_raw"
    case batchExport = "batch_export"

    // Filter Features
    case basicFilters = "basic_filters"
    case aiFilters = "ai_filters"
    case customFilters = "custom_filters"

    // Storage Features
    case cloudStorage = "cloud_storage"
    case unlimitedStorage = "unlimited_storage"
    case versionHistory = "version_history"

    // Collaboration Features
    case sharing = "sharing"
    case teamWorkspace = "team_workspace"
    case realTimeCollab = "realtime_collab"
}

// Organize products by user personas
ContentView()
    .withPurchases(products: [
        // Hobbyist
        Product("com.creativeapp.hobbyist", features: [
            .basicFilters, .exportHD, .cloudStorage
        ]),

        // Professional
        Product("com.creativeapp.pro", features: [
            .basicFilters, .aiFilters, .exportHD, .exportRAW,
            .batchExport, .cloudStorage, .sharing
        ]),

        // Studio/Team
        Product("com.creativeapp.studio", features: CreativeFeature.allCases)
    ])
```

#### **Best Practices**

1. **Use Descriptive Names**: `cloudSync` not `sync`
2. **Group Related Features**: Use enum cases that make logical sense
3. **Consider User Mental Models**: Features should match how users think about functionality
4. **Plan for Growth**: Design your feature enum to accommodate future additions
5. **Document Feature Purpose**: Add comments explaining what each feature unlocks

```swift
enum AppFeature: String, AppFeature, CaseIterable {
    // Storage & Sync
    case cloudSync = "cloud_sync"           // Sync data across devices
    case unlimitedStorage = "unlimited"     // Remove storage limits

    // Content Creation
    case advancedTools = "advanced_tools"   // Professional editing tools
    case batchProcessing = "batch"          // Process multiple items

    // Sharing & Collaboration
    case shareLinks = "share_links"         // Generate shareable links
    case teamWorkspace = "team_workspace"   // Multi-user collaboration

    // Support & Service
    case prioritySupport = "priority"       // Fast customer support
    case earlyAccess = "early_access"       // Beta features access
}
```

### Custom Premium Modifiers

Create your own premium gating logic:

```swift
extension View {
    func myCustomPremium<T: Hashable>(_ feature: T) -> some View {
        self.modifier(MyPremiumModifier(feature: feature))
    }
}
```

## 🛠️ Troubleshooting

### Error Handling

InAppKit handles errors gracefully and provides debugging information:

```swift
// Check for errors
if let error = InAppKit.shared.purchaseError {
    // Handle purchase error
}

// Purchase states
if InAppKit.shared.isPurchasing {
    // Show loading state
}
```

### Debugging

Enable detailed logging to debug StoreKit issues:

```swift
// InAppKit uses OSLog with category "statistics"
// Filter in Console.app or Xcode console for "statistics" messages
```

## ⚠️ Important Notes

### StoreKit Configuration
- Products must be configured in App Store Connect before testing
- Test with Sandbox accounts during development
- Features are automatically registered when using the fluent API
- Debug builds provide helpful warnings for unregistered features

### Testing & Validation
```swift
#if DEBUG
// Test purchases in development
InAppKit.shared.simulatePurchase("com.myapp.pro")
InAppKit.shared.clearPurchases() // Reset for testing
#endif
```

## 🔒 Privacy & Security

InAppKit follows Apple's privacy guidelines:
- No personal data collection
- All transactions handled by StoreKit
- Local feature validation only
- No analytics or tracking

## 🎯 Choose Your App's Monetization Pattern

### 📱 App Type: What Problem Do You Solve?

#### 🎨 **Creative Apps** (Photo, Video, Design)
**User Mindset**: *"I want to create something amazing"*

```swift
// Problem: User creates something, wants to share/export without limitations
enum CreativeFeature: String, InAppKit.AppFeature {
    case removeWatermark = "no_watermark"
    case hdExport = "hd_export"
    case premiumFilters = "premium_filters"
    case cloudStorage = "cloud_storage"
}

// Solution: Let them create first, then offer enhancement
ContentView()
    .withPurchases(products: [
        Product("com.creative.pro", features: CreativeFeature.allCases)
    ])
    .withPaywall { context in
        CreativePaywallView(triggeredBy: context.triggeredBy)
    }
```

#### 📊 **Productivity Apps** (Notes, Tasks, Documents)
**User Mindset**: *"I need this to work better/faster"*

```swift
// Problem: User accumulates data, needs more power/space
enum ProductivityFeature: String, InAppKit.AppFeature {
    case unlimitedItems = "unlimited_items"
    case advancedSearch = "advanced_search"
    case teamSync = "team_sync"
    case prioritySync = "priority_sync"
}

// Solution: Usage-based upgrades feel natural
Button("Add Project") {
    addProject()
}
.requiresPurchase(ProductivityFeature.unlimitedItems, when: projectCount > 5)
```

#### 🎮 **Entertainment Apps** (Games, Media, Social)
**User Mindset**: *"I want more fun/content"*

```swift
// Problem: User enjoys experience, wants more
enum EntertainmentFeature: String, InAppKit.AppFeature {
    case premiumContent = "premium_content"
    case noAds = "ad_free"
    case earlyAccess = "early_access"
    case specialFeatures = "special_features"
}

// Solution: Offer "more of what they love"
ContentView()
    .withPurchases(products: [
        Product("com.game.premium", features: EntertainmentFeature.allCases)
    ])
```

#### 💼 **Business Apps** (CRM, Finance, Analytics)
**User Mindset**: *"I need this for my business success"*

```swift
// Problem: User needs professional features for work
enum BusinessFeature: String, InAppKit.AppFeature {
    case teamAccounts = "team_accounts"
    case advancedReports = "advanced_reports"
    case apiAccess = "api_access"
    case prioritySupport = "priority_support"
}

// Solution: Clear business tiers
ContentView()
    .withPurchases(products: [
        Product("com.business.professional", features: [BusinessFeature.advancedReports, BusinessFeature.prioritySupport]),
        Product("com.business.enterprise", features: BusinessFeature.allCases)
    ])
```

### 🧠 User Psychology Patterns

#### "I'm Invested" Pattern
```swift
// User has data/content → natural to protect/enhance it
.requiresPurchase(AppFeature.backup, when: userContentCount > 20)
```

#### "I'm Professional" Pattern  
```swift
// User identity drives purchase → business features feel necessary
.requiresPurchase(AppFeature.clientSharing, when: isBusinessUser)
```

#### "I Hit a Wall" Pattern
```swift
// User reaches limitation → upgrade removes friction
.requiresPurchase(AppFeature.moreStorage, when: storageUsed > freeLimit)
```

#### "I Want More" Pattern
```swift
// User enjoys free features → wants enhanced experience
.requiresPurchase(AppFeature.premiumContent)
```

### 📋 Complete Implementation Guide: Photo Editing App

Here's a step-by-step implementation that shows how to use InAppKit's advanced features in a real app:

#### **Step 1: Define Your App Features**

```swift
import SwiftUI
import InAppKit

// Define app features aligned with business tiers
enum AppFeature: String, AppFeature, CaseIterable {
    // Basic tier features (always free)
    case basicFilters = "basic_filters"
    case cropResize = "crop_resize"

    // Pro tier features
    case advancedFilters = "advanced_filters"
    case batchProcessing = "batch_processing"
    case cloudStorage = "cloud_storage"

    // Professional tier features
    case rawSupport = "raw_support"
    case teamCollaboration = "team_collaboration"
    case prioritySupport = "priority_support"

    // Enterprise tier features
    case apiAccess = "api_access"
    case whiteLabeling = "white_labeling"
    case ssoIntegration = "sso_integration"
}
```

#### **Step 2: Configure Products with Marketing Enhancement**

```swift
@main
struct PhotoEditApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .withPurchases(products: [
                    // Pro Plan - Individual users
                    Product("com.photoapp.pro", features: [
                        AppFeature.advancedFilters,
                        AppFeature.batchProcessing,
                        AppFeature.cloudStorage
                    ])
                    .withBadge("Most Popular")
                    .withMarketingFeatures([
                        "AI-powered filters",
                        "Batch processing",
                        "Cloud storage"
                    ])
                    .withSavings("Save 30%"),

                    // Professional Plan - Power users
                    Product("com.photoapp.professional", features: [
                        AppFeature.advancedFilters,
                        AppFeature.batchProcessing,
                        AppFeature.cloudStorage,
                        AppFeature.rawSupport,
                        AppFeature.teamCollaboration,
                        AppFeature.prioritySupport
                    ])
                    .withBadge("Pro Choice")
                    .withMarketingFeatures([
                        "RAW file support",
                        "Team collaboration",
                        "Priority support"
                    ]),

                    // Enterprise Plan - Teams & organizations
                    Product("com.photoapp.enterprise", features: AppFeature.allCases)
                    .withBadge("Best Value")
                    .withMarketingFeatures([
                        "All features included",
                        "API access",
                        "White-label options"
                    ])
                ])
                .withPaywall { context in
                    PhotoAppPaywallView(context: context)
                }
        }
    }
}
```

#### **Step 3: Implement Feature Gating in UI**

```swift
struct ContentView: View {
    @State private var imageCount = 1
    @State private var isTeamMember = false
    @State private var selectedImages: [UIImage] = []

    var body: some View {
        VStack(spacing: 20) {
            Text("Photo Editor Pro")
                .font(.largeTitle.bold())

            // Always free - basic features
            Group {
                Button("Apply Basic Filter") {
                    applyBasicFilter()
                }
                .buttonStyle(.borderedProminent)

                Button("Crop & Resize") {
                    cropAndResize()
                }
                .buttonStyle(.bordered)
            }

            Divider()

            // Pro tier gating - shows paywall if not purchased
            Group {
                Button("Advanced AI Filter") {
                    applyAIFilter()
                }
                .requiresPurchase(AppFeature.advancedFilters)

                Button("Batch Process \(selectedImages.count) Images") {
                    batchProcess()
                }
                .requiresPurchase(AppFeature.batchProcessing, when: selectedImages.count > 5)

                Button("Save to Cloud") {
                    saveToCloud()
                }
                .requiresPurchase(AppFeature.cloudStorage)
            }

            Divider()

            // Professional tier gating
            Group {
                Button("Edit RAW Files") {
                    editRAW()
                }
                .requiresPurchase(AppFeature.rawSupport)

                Button("Team Collaboration") {
                    openTeamPanel()
                }
                .requiresPurchase(AppFeature.teamCollaboration, when: isTeamMember)
            }

            Divider()

            // Enterprise tier gating
            Button("Configure API Access") {
                configureAPI()
            }
            .requiresPurchase(AppFeature.apiAccess)

            Spacer()

            // Show current subscription status
            SubscriptionStatusView()
        }
        .padding()
    }

    // MARK: - Feature Implementation

    private func applyBasicFilter() {
        // Always available
        print("Applied basic filter")
    }

    private func cropAndResize() {
        // Always available
        print("Cropped and resized image")
    }

    private func applyAIFilter() {
        // Requires AppFeature.advancedFilters
        print("Applied AI-powered filter")
    }

    private func batchProcess() {
        // Requires AppFeature.batchProcessing when > 5 images
        print("Batch processing \(selectedImages.count) images")
    }

    private func saveToCloud() {
        // Requires AppFeature.cloudStorage
        print("Saved to cloud storage")
    }

    private func editRAW() {
        // Requires AppFeature.rawSupport
        print("Opened RAW editor")
    }

    private func openTeamPanel() {
        // Requires AppFeature.teamCollaboration
        print("Opened team collaboration panel")
    }

    private func configureAPI() {
        // Requires AppFeature.apiAccess
        print("Opened API configuration")
    }
}
```

#### **Step 4: Custom Paywall (Optional)**

```swift
struct PhotoAppPaywallView: View {
    let context: PaywallContext
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "camera.aperture")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)

                Text("Unlock Professional Photo Editing")
                    .font(.title.bold())
                    .multilineTextAlignment(.center)

                if let triggeredBy = context.triggeredBy {
                    Text("To use \(triggeredBy), upgrade to Pro")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            // Products - using enhanced PaywallContext
            VStack(spacing: 12) {
                ForEach(context.availableProducts, id: \.self) { product in
                    PurchaseOptionCard(
                        product: product,
                        isSelected: product == context.recommendedProduct,
                        onSelect: {
                            Task {
                                try await InAppKit.shared.purchase(product)
                                dismiss()
                            }
                        },
                        badge: context.badge(for: product),        // ✨ From context
                        features: context.marketingFeatures(for: product), // ✨ From context
                        savings: context.savings(for: product)    // ✨ From context
                    )
                }
            }

            // Alternative: Use the convenience property
            /*
            VStack(spacing: 12) {
                ForEach(context.productsWithMarketing, id: \.product) { item in
                    PurchaseOptionCard(
                        product: item.product,
                        isSelected: item.product == context.recommendedProduct,
                        onSelect: {
                            Task {
                                try await InAppKit.shared.purchase(item.product)
                                dismiss()
                            }
                        },
                        badge: item.badge,
                        features: item.features,
                        savings: item.savings
                    )
                }
            }
            */

            // Actions
            Button("Restore Purchases") {
                Task {
                    await InAppKit.shared.restorePurchases()
                    if InAppKit.shared.hasAnyPurchase {
                        dismiss()
                    }
                }
            }
            .foregroundColor(.blue)
        }
        .padding()
    }
}
```

#### **Step 5: Subscription Status Display**

```swift
struct SubscriptionStatusView: View {
    @State private var inAppKit = InAppKit.shared

    var body: some View {
        VStack(spacing: 8) {
            if inAppKit.hasAnyPurchase {
                Label("Pro Features Unlocked", systemImage: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.headline)

                // Show specific features user has access to
                VStack(alignment: .leading, spacing: 4) {
                    if inAppKit.hasAccess(to: AppFeature.advancedFilters) {
                        Text("• Advanced AI Filters")
                    }
                    if inAppKit.hasAccess(to: AppFeature.cloudStorage) {
                        Text("• Cloud Storage")
                    }
                    if inAppKit.hasAccess(to: AppFeature.rawSupport) {
                        Text("• RAW File Support")
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)
            } else {
                Label("Free Version", systemImage: "person.circle")
                    .foregroundColor(.orange)
                    .font(.headline)

                Text("Upgrade to unlock all features")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
```

#### **What This Implementation Demonstrates:**

- ✅ **Type-safe feature definitions** with `AppFeature` enum
- ✅ **Marketing-enhanced products** with badges, features, and savings
- ✅ **Conditional feature gating** based on usage patterns
- ✅ **Professional paywall integration** with context awareness
- ✅ **Real-time subscription status** display
- ✅ **Graceful feature degradation** for free users

#### **Expected User Experience:**

1. **Free users** can use basic filters and crop/resize
2. **When they try advanced features**, they see a contextual paywall
3. **After purchase**, all features unlock immediately
4. **Premium badges** appear on unlocked features
5. **Subscription status** is clearly displayed

This implementation follows InAppKit's design principles while providing a professional user experience that converts free users to paid subscribers.

## 🤝 Contributing

We welcome contributions! Here's how to get started:

### Development Setup

1. Fork the repository
2. Clone your fork: `git clone https://github.com/yourusername/InAppKit.git`
3. Create a feature branch: `git checkout -b feature/amazing-feature`
4. Make your changes and add tests
5. Run tests: `swift test`
6. Commit your changes: `git commit -m 'Add amazing feature'`
7. Push to your branch: `git push origin feature/amazing-feature`
8. Open a Pull Request

### Code Style

- Follow Swift API Design Guidelines
- Use meaningful variable and function names
- Add documentation comments for public APIs
- Maintain backward compatibility when possible

### 🐛 Bug Reports & Feature Requests

Please use [GitHub Issues](https://github.com/tddworks/InAppKit/issues) to report bugs or request features:

- **Bug Reports**: Include steps to reproduce, expected vs actual behavior
- **Feature Requests**: Describe the use case and proposed solution
- **Questions**: Check existing issues first, then create a new discussion

### 🌟 Show Your Support

If InAppKit helps your project, please consider:
- ⭐ Star this repository
- 🐛 Report bugs and suggest features
- 📖 Improve documentation
- 💬 Share your experience with the community

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built on Apple's StoreKit 2
- Inspired by SwiftUI's declarative approach
- Designed for modern iOS development

---

<div align="center">

**InAppKit** - Because in-app purchases shouldn't be complicated. 🚀

Made with ❤️ by the [TDDWorks](https://github.com/tddworks) team

</div>
