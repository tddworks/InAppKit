# Monetization Patterns

> **Choose the right strategy for your app's success**

Different apps need different monetization approaches. InAppKit adapts to how your users think about value, not just technical features.

## 📖 Table of Contents

- [Pattern Overview](#pattern-overview)
- [🎯 Try Before You Buy (Freemium)](#-try-before-you-buy-freemium)
- [💎 All-or-Nothing (Premium)](#-all-or-nothing-premium)
- [📅 Ongoing Value (Subscription)](#-ongoing-value-subscription)
- [🏪 Feature Store](#-feature-store)
- [📱 Platform-Specific Patterns](#-platform-specific-patterns)
- [How to Choose](#how-to-choose)

## Pattern Overview

| Pattern | Best For | User Mental Model | InAppKit Setup |
|---------|----------|-------------------|----------------|
| **Freemium** | Apps where users need to experience value | *"I love this app, now I want more"* | Multiple tiers |
| **Premium** | Apps with clear immediate value | *"This solves my problem right now"* | Single unlock |
| **Subscription** | Apps providing ongoing value/content | *"I use this regularly"* | Time-based features |
| **Feature Store** | Power user apps with many features | *"I'll buy what I need"* | Individual features |

## 🎯 Try Before You Buy (Freemium)

**Perfect for**: Apps where users need to experience value first

### User Mental Model
*"I love this app, now I want more powerful features"*

### Implementation

```swift
enum PhotoFeature: String, AppFeature {
    case advancedFilters = "advanced_filters"
    case cloudStorage = "cloud_storage"
    case batchProcessing = "batch_processing"
    case rawSupport = "raw_support"
}

ContentView()
    .withPurchases(products: [
        Product("com.photoapp.basic", features: [PhotoFeature.advancedFilters]),
        Product("com.photoapp.pro", features: [
            PhotoFeature.advancedFilters,
            PhotoFeature.cloudStorage,
            PhotoFeature.batchProcessing
        ]),
        Product("com.photoapp.professional", features: PhotoFeature.allCases)
    ])
```

### Example: Photo Editing App

```swift
struct FiltersView: View {
    var body: some View {
        ScrollView {
            // Free filters
            FilterRow("Basic", "Vintage", "BW")

            // Premium filters
            FilterRow("HDR", "Portrait", "Cinematic")
                .requiresPurchase(PhotoFeature.advancedFilters)
        }
    }
}
```

### ✅ **Freemium Benefits**
- Users understand the upgrade value
- Natural conversion funnel
- Word-of-mouth growth

### ⚠️ **Freemium Challenges**
- Must provide enough free value to hook users
- Complex feature tier management

## 💎 All-or-Nothing (Premium)

**Perfect for**: Apps with clear, immediate value proposition

### User Mental Model
*"This solves my problem right now, I'll pay upfront"*

### Implementation

```swift
enum UtilityFeature: String, AppFeature {
    case fullAccess = "full_access"
}

ContentView()
    .withPurchases("com.utilityapp.pro")

// Gate everything behind purchase
MainAppView()
    .requiresPurchase()
```

### Example: Professional Tool

```swift
struct CalculatorView: View {
    var body: some View {
        VStack {
            Text("Scientific Calculator Pro")

            if InAppKit.shared.hasAccess(to: "com.calculatorapp.pro") {
                AdvancedCalculatorView()
            } else {
                Text("Try 3 calculations free")
                BasicCalculatorView(limit: 3)
                    .requiresPurchase(when: calculationCount > 3)
            }
        }
    }
}
```

### ✅ **Premium Benefits**
- Simple to implement and understand
- Higher revenue per user
- Clear value proposition

### ⚠️ **Premium Challenges**
- Higher barrier to entry
- Must convince users before they experience value

## 📅 Ongoing Value (Subscription)

**Perfect for**: Apps providing regular updates, content, or cloud services

### User Mental Model
*"I use this regularly and it keeps getting better"*

### Implementation

```swift
enum SubscriptionFeature: String, AppFeature {
    case premiumContent = "premium_content"
    case cloudSync = "cloud_sync"
    case prioritySupport = "priority_support"
    case earlyAccess = "early_access"
}

ContentView()
    .withPurchases(products: [
        Product("com.newsapp.monthly", features: [SubscriptionFeature.premiumContent]),
        Product("com.newsapp.annual", features: [
            SubscriptionFeature.premiumContent,
            SubscriptionFeature.cloudSync,
            SubscriptionFeature.prioritySupport
        ])
    ])
```

### Example: Content App

```swift
struct ArticleView: View {
    let article: Article

    var body: some View {
        VStack {
            Text(article.title)
            Text(article.preview)

            if article.isPremium {
                Text("Continue reading...")
                    .requiresPurchase(SubscriptionFeature.premiumContent)
            } else {
                Text(article.fullContent)
            }
        }
    }
}
```

### ✅ **Subscription Benefits**
- Predictable recurring revenue
- Justifies ongoing development
- Higher lifetime value

### ⚠️ **Subscription Challenges**
- Must continuously provide value
- Subscription fatigue among users

## 🏪 Feature Store

**Perfect for**: Power user apps with many specialized features

### User Mental Model
*"I'll buy exactly what I need for my workflow"*

### Implementation

```swift
enum DesignFeature: String, AppFeature {
    case vectorTools = "vector_tools"
    case aiGeneration = "ai_generation"
    case teamCollaboration = "team_collaboration"
    case advancedExport = "advanced_export"
    case pluginSupport = "plugin_support"
}

ContentView()
    .withPurchases(products: [
        Product("com.designapp.vectors", features: [DesignFeature.vectorTools]),
        Product("com.designapp.ai", features: [DesignFeature.aiGeneration]),
        Product("com.designapp.team", features: [DesignFeature.teamCollaboration]),
        Product("com.designapp.export", features: [DesignFeature.advancedExport]),
        Product("com.designapp.everything", features: DesignFeature.allCases)
    ])
```

### Example: Design Tool

```swift
struct ToolbarView: View {
    var body: some View {
        HStack {
            BasicTools()

            VectorToolsButton()
                .requiresPurchase(DesignFeature.vectorTools)

            AIGenerationButton()
                .requiresPurchase(DesignFeature.aiGeneration)

            ExportButton()
                .requiresPurchase(DesignFeature.advancedExport)
        }
    }
}
```

### ✅ **Feature Store Benefits**
- Users pay only for what they use
- Flexible pricing strategy
- Can appeal to different user segments

### ⚠️ **Feature Store Challenges**
- Complex feature management
- Can be overwhelming for casual users

## 📱 Platform-Specific Patterns

### iOS App Store Patterns

#### Games & Entertainment
```swift
enum GameFeature: String, AppFeature {
    case removeAds = "remove_ads"
    case unlockLevels = "unlock_levels"
    case powerUps = "power_ups"
    case customization = "customization"
}

// Common: Remove ads + premium content
Product("com.game.premium", features: [
    GameFeature.removeAds,
    GameFeature.unlockLevels,
    GameFeature.powerUps
])
```

#### Productivity Apps
```swift
enum ProductivityFeature: String, AppFeature {
    case cloudSync = "cloud_sync"
    case advancedFeatures = "advanced_features"
    case prioritySupport = "priority_support"
    case teamFeatures = "team_features"
}

// Common: Freemium with feature tiers
Product("com.productivity.pro", features: [
    ProductivityFeature.cloudSync,
    ProductivityFeature.advancedFeatures
])
```

#### Creative Apps
```swift
enum CreativeFeature: String, AppFeature {
    case professionalTools = "professional_tools"
    case exportFormats = "export_formats"
    case cloudStorage = "cloud_storage"
    case collaborationTools = "collaboration_tools"
}

// Common: Tool-based purchases
Product("com.creative.pro", features: CreativeFeature.allCases)
```

## How to Choose

### Questions to Ask

1. **How quickly can users see value?**
   - Immediate → Premium
   - Need to try → Freemium

2. **What type of value do you provide?**
   - One-time tool → Premium
   - Ongoing content → Subscription
   - Multiple tools → Feature Store

3. **Who are your users?**
   - Casual users → Freemium
   - Professionals → Premium or Feature Store
   - Regular users → Subscription

4. **How complex is your app?**
   - Simple → Premium
   - Many features → Freemium or Feature Store
   - Content-driven → Subscription

### Decision Matrix

| If your app is... | Choose |
|-------------------|--------|
| A utility that solves one problem well | **Premium** |
| Feature-rich with broad appeal | **Freemium** |
| Content or service-based | **Subscription** |
| Professional tool with many features | **Feature Store** |

---

**Ready to implement?** → **[Customization Guide](customization.md)** to add marketing features and custom UI

**Need technical details?** → **[API Reference](api-reference.md)** for complete documentation