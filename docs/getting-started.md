# Getting Started with InAppKit

> **Learn the core concepts and build your first premium feature in 10 minutes**

## 📖 Table of Contents

- [Understanding the Basics](#understanding-the-basics)
- [Product API Guidelines](#product-api-guidelines)
- [Step-by-Step Tutorial](#step-by-step-tutorial)
- [Common Patterns](#common-patterns)
- [What's Next](#whats-next)

## Understanding the Basics

InAppKit works with three simple concepts:

### 1. **Products** - What users can buy
```swift
Product("com.yourapp.pro")  // A product ID from App Store Connect
```

### 2. **Features** - What gets unlocked
```swift
enum AppFeature: String, AppFeature {
    case removeAds = "remove_ads"
    case cloudSync = "cloud_sync"
    case exportPDF = "export_pdf"
}
```

### 3. **Paywalls** - How users purchase
```swift
.withPaywall { context in
    Text("Upgrade to Pro!")  // Your custom paywall UI
}
```

## Product API Guidelines

InAppKit uses a consistent Product API pattern:

> **Simple rule**: *Need features? Always use `features:` parameter*

### ✅ Correct Syntax

```swift
// No features
Product("com.app.basic")

// Enum features
Product("com.app.pro", features: [AppFeature.sync, AppFeature.export])

// All enum cases
Product("com.app.premium", features: AppFeature.allCases)

// String features (for simple cases)
Product("com.app.custom", features: ["feature1", "feature2"])
```

### ❌ Avoid These Patterns

```swift
// Don't use unlabeled parameters (removed for consistency)
Product("com.app.pro", [.sync, .export])          // ❌
Product("com.app.premium", AppFeature.allCases)    // ❌
```

## Step-by-Step Tutorial

Let's build a note-taking app with premium features.

### Step 1: Define Your Features

```swift
import InAppKit

enum NoteFeature: String, AppFeature {
    case unlimitedNotes = "unlimited_notes"
    case cloudSync = "cloud_sync"
    case exportPDF = "export_pdf"
    case customThemes = "custom_themes"
}
```

### Step 2: Configure Products

```swift
ContentView()
    .withPurchases(products: [
        Product("com.noteapp.pro", features: [
            NoteFeature.unlimitedNotes,
            NoteFeature.cloudSync,
            NoteFeature.exportPDF
        ]),
        Product("com.noteapp.premium", features: NoteFeature.allCases)
    ])
```

### Step 3: Gate Premium Features

```swift
struct NotesListView: View {
    var body: some View {
        VStack {
            // Free content
            ForEach(freeNotes) { note in
                NoteRow(note: note)
            }

            // Premium content
            ForEach(premiumNotes) { note in
                NoteRow(note: note)
                    .requiresPurchase(NoteFeature.unlimitedNotes)
            }

            // Export button
            Button("Export PDF") {
                exportToPDF()
            }
            .requiresPurchase(NoteFeature.exportPDF)
        }
    }
}
```

### Step 4: Add Custom Paywall (Optional)

```swift
ContentView()
    .withPurchases(products: [...])
    .withPaywall { context in
        VStack {
            Text("Unlock Premium Features")
                .font(.title)

            ForEach(context.availableProducts, id: \\.id) { product in
                ProductRow(product: product)
            }
        }
        .padding()
    }
```

### Step 5: Check Purchase Status in Code

```swift
struct ExportButton: View {
    @State private var canExport = false

    var body: some View {
        Button("Export PDF") {
            exportToPDF()
        }
        .disabled(!canExport)
        .onAppear {
            canExport = InAppKit.shared.hasAccess(to: NoteFeature.exportPDF)
        }
    }
}
```

## Common Patterns

### Pattern 1: Simple Premium Upgrade

```swift
// One product unlocks everything
ContentView()
    .withPurchases("com.app.pro")

Text("Premium Feature")
    .requiresPurchase()  // Uses default product
```

### Pattern 2: Feature-Based Tiers

```swift
// Different products unlock different features
ContentView()
    .withPurchases(products: [
        Product("com.app.basic", features: [Feature.removeAds]),
        Product("com.app.pro", features: [Feature.removeAds, Feature.cloudSync]),
        Product("com.app.premium", features: Feature.allCases)
    ])
```

### Pattern 3: Subscription with Features

```swift
// Combine subscriptions with feature gating
ContentView()
    .withPurchases(products: [
        Product("com.app.monthly", features: [Feature.premiumContent]),
        Product("com.app.annual", features: [Feature.premiumContent, Feature.prioritySupport])
    ])
```

### Pattern 4: Automatic Discount Calculation

```swift
// Show calculated savings to encourage annual subscriptions
ContentView()
    .withPurchases(products: [
        Product("com.app.monthly", features: features),
        Product("com.app.yearly", features: features)
            .withRelativeDiscount(comparedTo: "com.app.monthly")
            // Automatically displays "Save 31%" (calculated from actual prices)
            .withBadge("Best Value", color: .green)
    ])
```

**Different Display Styles:**
```swift
// Show dollar amount saved
.withRelativeDiscount(comparedTo: "monthly", style: .amount)
// Displays: "Save $44"

// Show free months
.withRelativeDiscount(comparedTo: "monthly", style: .freeTime)
// Displays: "2 months free"

// Custom color
.withRelativeDiscount(comparedTo: "monthly", color: .purple)
// Displays in purple instead of default orange
```

### Pattern 5: Freemium with Limits

```swift
struct ContentView: View {
    @State private var notesCount = 0

    var body: some View {
        VStack {
            if notesCount >= 5 {
                Text("Create unlimited notes")
                    .requiresPurchase(Feature.unlimitedNotes)
            } else {
                Button("Add Note") { notesCount += 1 }
            }
        }
    }
}
```

## What's Next

### 🎯 Choose Your Strategy
**[Monetization Patterns →](monetization-patterns.md)**
Learn which pattern fits your app best

### 🎨 Customize Your Experience
**[Customization Guide →](customization.md)**
Add marketing info, custom UI, and advanced features

### 📖 Explore Advanced Features
**[API Reference →](api-reference.md)**
Complete documentation and advanced configuration

---

**Questions?** Check our [troubleshooting guide](api-reference.md#troubleshooting) or [open an issue](https://github.com/tddworks/InAppKit/issues).