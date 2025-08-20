# InAppKit

[![Swift Package Manager](https://img.shields.io/badge/SPM-Compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![Platform](https://img.shields.io/badge/Platform-iOS%2017%2B%20%7C%20macOS%2015%2B%20%7C%20watchOS%2010%2B%20%7C%20tvOS%2017%2B-blue.svg)](https://developer.apple.com/)
[![Swift](https://img.shields.io/badge/Swift-6.1%2B-orange.svg)](https://swift.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A modern, SwiftUI-native framework that simplifies StoreKit integration with a fluent, chainable API and feature-first approach. Built for iOS 17+, macOS 15+, watchOS 10+, and tvOS 17+.

> 🚀 **InAppKit** - Because in-app purchases shouldn't be complicated.

## 📖 Table of Contents

- [✨ Features](#-features)
- [🚧 Requirements](#-requirements)
- [📦 Installation](#-installation)
- [🚀 Quick Start](#-quick-start)
- [💡 Examples](#-examples)
- [📖 Core Concepts](#-core-concepts)
- [🔐 Type-Safe Premium Gating](#-type-safe-premium-gating)
- [🎨 Paywall & UI Customization](#-paywall--ui-customization)
- [🏗️ Architecture](#️-architecture)
- [🎯 Advanced Usage](#-advanced-usage)
- [🛠️ Troubleshooting](#️-troubleshooting)
- [🔒 Privacy & Security](#-privacy--security)
- [🤝 Contributing](#-contributing)
- [📄 License](#-license)

## ✨ Features

- **🔗 Fluent Chainable API** - Chain configuration methods directly on views
- **🎯 Feature-First Design** - Define features, not just products
- **🎨 Customizable Paywalls** - Built-in modern paywall with full customization
- **🔐 Type-Safe Gating** - `.requiresPurchase()` with intelligent conditions
- **🎭 Context-Aware** - Smart paywall context based on user actions
- **⚡ Zero Boilerplate** - Minimal setup, maximum functionality
- **🔄 Automatic Management** - Transaction listening and state updates
- **🛡️ Type-Safe** - Full Swift type safety with generics
- **📱 Cross-Platform** - iOS, macOS, watchOS, tvOS support
- **🎨 Built-in UI Components** - Premium badges, paywall views, and more

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

### 1. Define Your Features

```swift
enum AppFeature: String, InAppKit.AppFeature {
    case multipleAccounts = "multiple_accounts"
    case advancedSync = "advanced_sync"
    case prioritySupport = "priority_support"
}
```

### 2. Configure Your App

```swift
import SwiftUI
import InAppKit

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .withPurchases(products: [
                    Product("com.yourapp.pro", AppFeature.allCases)
                ])
                .withPaywall { context in
                    CustomPaywallView(
                        triggeredBy: context.triggeredBy,
                        products: context.availableProducts
                    )
                }
                .withTerms { TermsView() }
                .withPrivacy { PrivacyView() }
        }
    }
}
```

### 3. Gate Premium Features

```swift
struct ContentView: View {
    @State private var syncCount = 0
    @State private var fileSize = 5
    
    var body: some View {
        VStack {
            // Simple premium gating
            Button("Advanced Feature") {
                performAdvancedAction()
            }
            .requiresPurchase(AppFeature.multipleAccounts)
            
            // Conditional gating
            Button("Sync Now") {
                sync()
            }
            .requiresPurchase(AppFeature.advancedSync, when: syncCount > 5)
            
            // Usage-based gating
            Button("Export Large File") {
                exportFile()
            }
            .requiresPurchase(AppFeature.export, when: fileSize > 10.mb)
            
            // Smart conditional gating
            Button("Bulk Operations") {
                bulkProcess()
            }
            .requiresPurchase { syncCount > 100 || fileSize > 50.mb }
        }
    }
}
```

## 💡 Examples

### Basic Premium Feature

```swift
Button("Export PDF") {
    exportToPDF()
}
.requiresPurchase(AppFeature.export)
```

### Conditional Gating

```swift
Button("Sync Files") {
    syncFiles()
}
.requiresPurchase(AppFeature.cloudSync, when: fileCount > 10)
```

### Custom Paywall

```swift
ContentView()
    .withPurchases(products: [Product("com.app.pro", AppFeature.allCases)])
    .withPaywall { context in
        VStack {
            Text("Unlock \(context.triggeredBy ?? "premium features")")
            ForEach(context.availableProducts, id: \.self) { product in
                Button("Buy \(product.displayName)") {
                    Task { try await InAppKit.shared.purchase(product) }
                }
            }
        }
    }
```

## 📖 Core Concepts

### Features

Features represent functionality in your app that can be locked behind purchases. Use the `AppFeature` protocol for type-safe feature definitions:

```swift
Product("com.app.pro", AppFeature.allCases)
```

### Multiple Product Tiers

InAppKit supports sophisticated product tier strategies for your business model:

```swift
// Basic Tier - Entry-level features
Product("com.myapp.basic", [AppFeature.themes, AppFeature.basicExport])

// Pro Tier - Power user features  
Product("com.myapp.pro", [AppFeature.unlimited, AppFeature.advancedExport, AppFeature.cloudSync])

// Enterprise Tier - All features
Product("com.myapp.enterprise", AppFeature.allCases)

// Subscription Tiers
Product("com.myapp.monthly", [AppFeature.premium, AppFeature.support])
Product("com.myapp.yearly", AppFeature.allCases)
```

**Business Use Cases:**
- **Freemium Model**: Offer basic features free, premium features behind paywall
- **Good-Better-Best**: Multiple tiers with increasing value proposition
- **Feature Bundles**: Group related features into logical product tiers
- **Subscription Tiers**: Different subscription levels with different feature sets

### API Design Philosophy

InAppKit uses a **fluent chainable API** for clean, readable configuration:

```swift
ContentView()
    .withPurchases(products: [Product("com.app.pro", AppFeature.allCases)])
    .withPaywall { context in CustomPaywall(context) }
    .withTerms { TermsView() }
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

### Simple Gating

```swift
// Feature gating (type-safe with protocols)
.requiresPurchase()                          // Any premium
.requiresPurchase("com.app.pro")             // Specific product  
.requiresPurchase(AppFeature.cloudSync)      // Specific feature

// Examples in context
Text("Premium Content")
    .requiresPurchase()

Button("Advanced Action") { }
    .requiresPurchase(AppFeature.advanced)

Image("Premium Icon")
    .requiresPurchase("com.app.pro")
```

### Conditional & Usage-Based Gating

```swift
// Conditional gating (all variants)
.requiresPurchase(when: condition)                    // Any premium, conditional
.requiresPurchase("com.app.pro", when: condition)    // Specific product, conditional
.requiresPurchase(AppFeature.export, when: condition) // Specific feature, conditional

// Usage-based gating with closures
.requiresPurchase(when: { count > 100 })             // Closure condition
.requiresPurchase(AppFeature.export, when: { size > 10.mb }) // Feature + closure

// Convenience methods for common patterns
.requiresPurchase(whenItemCount: count, exceeds: 100)
.requiresPurchase(AppFeature.export, whenFileSize: size, exceeds: 50.mb)

// Examples in context
Button("Export") { }
    .requiresPurchase(AppFeature.export, when: documentCount > 10)

Button("Advanced Export") { }
    .requiresPurchase { documentCount > 100 || fileSize > 10.mb }

Button("Large File Export") { }
    .requiresPurchase(AppFeature.export, whenFileSize: fileSize, exceeds: 50.mb)

Button("Pro Features") { }
    .requiresPurchase("com.app.pro", when: userLevel > 5)
```

### Custom Gating Behavior

The premium modifier shows a badge and disables interaction for non-premium users. When tapped, it presents the configured paywall.

### Convenience Features

```swift
// File size helpers
let size = 10.mb  // or 10.MB
let bigSize = 2.gb // Future: support for GB, TB

// Usage-based convenience methods
.requiresPurchase(whenItemCount: count, exceeds: 100)
.requiresPurchase(AppFeature.export, whenFileSize: size, exceeds: 50.mb)

// Smart conditional logic
.requiresPurchase { complexCondition() && anotherCheck() }
```

## 🏗️ Architecture

### InAppKit

The core singleton that manages all StoreKit operations:

```swift
// Check purchase status
InAppKit.shared.hasAnyPurchase
InAppKit.shared.isPurchased("com.app.pro")
InAppKit.shared.hasAccess(to: AppFeature.advanced)

// Manual operations
await InAppKit.shared.purchase(product)
await InAppKit.shared.restorePurchases()
```

### View Modifiers

- `.withPurchases()` - Start fluent configuration chain
- `.withPaywall()` - Add paywall to configuration chain
- `.withTerms()` - Add terms view to configuration chain
- `.withPrivacy()` - Add privacy view to configuration chain
- `.requiresPurchase()` - Type-safe premium gating with multiple variants

### Premium Gating API Overview

```swift
// All available .requiresPurchase() variants
.requiresPurchase()                                    // Any purchase
.requiresPurchase("productId")                         // Specific product
.requiresPurchase(AppFeature.feature)                  // Specific feature
.requiresPurchase(when: Bool)                         // Conditional any
.requiresPurchase("productId", when: Bool)            // Conditional product
.requiresPurchase(AppFeature.feature, when: Bool)     // Conditional feature
.requiresPurchase(when: () -> Bool)                   // Closure condition
.requiresPurchase(AppFeature.feature, when: () -> Bool) // Feature + closure
.requiresPurchase(whenItemCount: Int, exceeds: Int)   // Item count helper
.requiresPurchase(AppFeature.feature, whenFileSize: Int, exceeds: Int) // File size helper
```

### Core Types

- `InAppKit` - Main singleton for StoreKit operations
- `AppFeature` - Protocol for type-safe feature definitions
- `PaywallContext` - Context information for paywall presentation
- `ProductConfig` - Product configuration with features

## 🎯 Advanced Usage

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

### Complete Implementation Guide: Photo Editing App

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
