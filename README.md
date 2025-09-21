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
enum AppFeature: String, InAppKit.AppFeature {
    case removeAds = "remove_ads"
    case cloudSync = "cloud_sync"
    case exportPDF = "export_pdf"
}

ContentView()
    .withPurchases(products: [
        Product("com.yourapp.pro", AppFeature.allCases)
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
Product("com.app.pro", [.noAds, .cloudSync, .export])
```

### Choose Your Monetization Strategy

InAppKit adapts to how your users think about value, not just technical features:

#### 🎯 "Try Before You Buy" (Freemium)
*Perfect for: Apps where users need to experience value first*

```swift
// Users get core functionality, pay for advanced features
Product("com.photoapp.pro", [AppFeature.advancedFilters, AppFeature.cloudStorage])
```

**User Mental Model**: *"I love this app, now I want more powerful features"*
- ✅ Users understand the upgrade value
- ✅ Natural conversion from free to paid
- ✅ Low barrier to entry

#### 🏆 "Good, Better, Best" (Tiered Value)
*Perfect for: Different user types with different needs*

```swift
// Starter: Casual users
Product("com.designapp.starter", [AppFeature.basicTemplates, AppFeature.export])

// Professional: Power users  
Product("com.designapp.pro", [AppFeature.premiumTemplates, AppFeature.advancedExport, AppFeature.teamSharing])

// Enterprise: Teams & organizations
Product("com.designapp.enterprise", AppFeature.allCases)
```

**User Mental Model**: *"I know what level of user I am, show me my tier"*
- ✅ Clear value differentiation
- ✅ Room for users to grow
- ✅ Predictable pricing psychology

#### 📦 "Feature Packs" (Bundled Solutions)
*Perfect for: Specialized workflows and use cases*

```swift
// Content Creator Pack
Product("com.videoapp.creator", [AppFeature.advancedEditing, AppFeature.exportFormats, AppFeature.musicLibrary])

// Business Pack
Product("com.videoapp.business", [AppFeature.branding, AppFeature.analytics, AppFeature.teamWorkspace])
```

**User Mental Model**: *"I need tools for my specific workflow"*
- ✅ Solves complete user problems
- ✅ Higher perceived value
- ✅ Targets specific personas

#### ⏰ "Ongoing Value" (Subscriptions)
*Perfect for: Services that provide continuous value*

```swift
// Monthly: Try it out
Product("com.cloudapp.monthly", [AppFeature.cloudSync, AppFeature.prioritySupport])

// Annual: Committed users
Product("com.cloudapp.annual", [AppFeature.cloudSync, AppFeature.prioritySupport, AppFeature.advancedFeatures])
```

**User Mental Model**: *"I'm paying for ongoing service and updates"*
- ✅ Matches recurring value delivery
- ✅ Lower monthly commitment
- ✅ Incentivizes annual savings

### API Design Philosophy

InAppKit uses a **fluent chainable API** for clean, readable configuration:

```swift
ContentView()
    .withPurchases(products: [Product("com.app.pro", AppFeature.allCases)])
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

### Custom Paywall

Create your own paywall with full context information:

```swift
// Context-aware paywall with fluent API
ContentView()
    .withPurchases(products: products)
    .withPaywall { context in
        VStack {
            Text("Upgrade to unlock \(context.triggeredBy ?? "premium features")")
            
            ForEach(context.availableProducts, id: \.self) { product in
                Button(product.displayName) {
                    Task {
                        try await InAppKit.shared.purchase(product)
                    }
                }
            }
            
            if let recommended = context.recommendedProduct {
                Text("Recommended: \(recommended.displayName)")
            }
        }
    }
```

### Paywall Context

The `PaywallContext` provides rich information about how the paywall was triggered:

```swift
public struct PaywallContext {
    public let triggeredBy: String?        // What action triggered this
    public let availableProducts: [StoreKit.Product] // Products that can be purchased  
    public let recommendedProduct: StoreKit.Product?  // Best product recommendation
}
```

### Built-in UI Components

InAppKit provides several built-in UI components:

- **`PaywallView`** - Modern, animated paywall with product selection
- **`PurchaseRequiredBadge`** - Premium crown badge overlay  
- **`TermsPrivacyFooter`** - Configurable footer for terms and privacy
- **`FeatureRow`** - Styled feature list rows
- **`ModernProductCard`** - Product selection cards

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
.withPurchases(products: [Product("com.app.pro", AppFeature.allCases)])
```

## 🎯 Advanced Features

### Multiple Product Tiers in Practice

```swift
// E-commerce App Example
ContentView()
    .withPurchases(products: [
        Product("com.shopapp.basic", [AppFeature.trackOrders, AppFeature.wishlist]),
        Product("com.shopapp.plus", [AppFeature.trackOrders, AppFeature.wishlist, AppFeature.fastShipping]),
        Product("com.shopapp.premium", AppFeature.allCases)
    ])
    .withPaywall { context in
        ShopPaywallView(context: context)
    }

// Productivity App Example  
ContentView()
    .withPurchases(products: [
        Product("com.prodapp.starter", [AppFeature.basicProjects]),
        Product("com.prodapp.professional", [AppFeature.basicProjects, AppFeature.teamCollaboration, AppFeature.advancedReports]),
        Product("com.prodapp.enterprise", AppFeature.allCases)
    ])

// Media App Subscription Tiers
ContentView()
    .withPurchases(products: [
        Product("com.mediaapp.monthly", [AppFeature.hdStreaming, AppFeature.downloads]),
        Product("com.mediaapp.annual", [AppFeature.hdStreaming, AppFeature.downloads, AppFeature.offlineMode, AppFeature.familySharing])
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
        Product("com.creative.pro", CreativeFeature.allCases)
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
        Product("com.game.premium", EntertainmentFeature.allCases)
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
        Product("com.business.professional", [BusinessFeature.advancedReports, BusinessFeature.prioritySupport]),
        Product("com.business.enterprise", BusinessFeature.allCases)
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

### Complete Implementation: Photo Editing App

```swift
import SwiftUI
import InAppKit

// Define app features aligned with business tiers
enum AppFeature: String, InAppKit.AppFeature {
    // Basic tier features
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

@main
struct PhotoEditApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .withPurchases(products: [
                    // Freemium: Basic features included free
                    Product("com.photoapp.pro", [
                        AppFeature.advancedFilters, 
                        AppFeature.batchProcessing, 
                        AppFeature.cloudStorage
                    ]),
                    Product("com.photoapp.professional", [
                        AppFeature.advancedFilters, 
                        AppFeature.batchProcessing, 
                        AppFeature.cloudStorage,
                        AppFeature.rawSupport, 
                        AppFeature.teamCollaboration, 
                        AppFeature.prioritySupport
                    ]),
                    Product("com.photoapp.enterprise", AppFeature.allCases)
                ])
                .withPaywall { context in
                    PhotoAppPaywallView(
                        triggeredBy: context.triggeredBy,
                        products: context.availableProducts
                    )
                }
        }
    }
}

struct ContentView: View {
    @State private var imageCount = 1
    @State private var isTeamMember = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Always free - basic features
            Button("Apply Basic Filter") { applyBasicFilter() }
            Button("Crop & Resize") { cropAndResize() }
            
            // Pro tier gating
            Button("Advanced AI Filter") { applyAIFilter() }
                .requiresPurchase(AppFeature.advancedFilters)
            
            Button("Batch Process") { batchProcess() }
                .requiresPurchase(AppFeature.batchProcessing, when: imageCount > 5)
            
            // Professional tier gating
            Button("Edit RAW Files") { editRAW() }
                .requiresPurchase(AppFeature.rawSupport)
            
            Button("Team Collaboration") { openTeamPanel() }
                .requiresPurchase(AppFeature.teamCollaboration, when: isTeamMember)
            
            // Enterprise tier gating
            Button("API Access") { configureAPI() }
                .requiresPurchase(AppFeature.apiAccess)
        }
    }
}
```

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
