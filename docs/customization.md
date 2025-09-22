# Customization Guide

> **Make InAppKit match your app's design and boost conversions**

InAppKit provides beautiful defaults but gives you full control over the user experience.

## 📖 Table of Contents

- [Marketing-Enhanced Products](#marketing-enhanced-products)
- [Custom Paywalls](#custom-paywalls)
- [Product Configuration](#product-configuration)
- [UI Customization](#ui-customization)
- [Advanced Configuration](#advanced-configuration)

## Marketing-Enhanced Products

Boost conversion rates with badges, feature highlights, and savings displays.

### Adding Marketing Information

```swift
ContentView()
    .withPurchases(products: [
        Product("com.app.basic", features: [Feature.removeAds])
            .withBadge("Popular", color: .orange)
            .withMarketingFeatures(["No ads", "Basic support"]),

        Product("com.app.pro", features: [Feature.removeAds, Feature.cloudSync])
            .withBadge("Best Value", color: .green)
            .withMarketingFeatures([
                "Everything in Basic",
                "Cloud sync across devices",
                "Priority support"
            ])
            .withSavings("Save 30%"),

        Product("com.app.premium", features: Feature.allCases)
            .withBadge("Professional", color: .purple)
            .withMarketingFeatures([
                "Everything in Pro",
                "Advanced analytics",
                "Team collaboration",
                "API access"
            ])
            .withSavings("Save 50%")
    ])
```

### Accessing Marketing Information

```swift
struct PaywallView: View {
    let context: PaywallContext

    var body: some View {
        VStack {
            ForEach(context.availableProducts, id: \\.id) { product in
                ProductCard(
                    product: product,
                    badge: context.badge(for: product),
                    features: context.marketingFeatures(for: product),
                    savings: context.savings(for: product)
                )
            }
        }
    }
}

struct ProductCard: View {
    let product: Product
    let badge: String?
    let features: [String]?
    let savings: String?

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(product.displayName)
                    .font(.headline)

                if let badge = badge {
                    Text(badge)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
            }

            if let features = features {
                ForEach(features, id: \\.self) { feature in
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(feature)
                    }
                    .font(.caption)
                }
            }

            HStack {
                Text(product.displayPrice)
                    .font(.title2)
                    .fontWeight(.bold)

                if let savings = savings {
                    Text(savings)
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}
```

## Custom Paywalls

Create paywalls that match your app's design and optimize for conversion.

### Basic Custom Paywall

```swift
ContentView()
    .withPurchases(products: [...])
    .withPaywall { context in
        VStack {
            Text("Unlock Premium Features")
                .font(.title)
                .fontWeight(.bold)

            Text("Get the most out of your app")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()

            ForEach(context.availableProducts, id: \\.id) { product in
                PurchaseButton(product: product)
            }

            Spacer()

            Button("Restore Purchases") {
                InAppKit.shared.restorePurchases()
            }
            .font(.caption)
        }
        .padding()
    }
```

### Advanced Paywall with Animation

```swift
struct AnimatedPaywallView: View {
    let context: PaywallContext
    @State private var showFeatures = false

    var body: some View {
        VStack {
            Text("Upgrade to Pro")
                .font(.largeTitle)
                .fontWeight(.bold)

            if showFeatures {
                FeatureListView()
                    .transition(.slide)
            }

            ProductGridView(products: context.availableProducts)

            Button("Maybe Later") {
                // Dismiss paywall
            }
            .foregroundColor(.secondary)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8)) {
                showFeatures = true
            }
        }
    }
}
```

### Paywall with Custom Triggers

```swift
struct FeatureGateView: View {
    @State private var showPaywall = false

    var body: some View {
        VStack {
            Button("Export to PDF") {
                if InAppKit.shared.hasAccess(to: Feature.exportPDF) {
                    exportToPDF()
                } else {
                    showPaywall = true
                }
            }
        }
        .sheet(isPresented: $showPaywall) {
            CustomPaywallView(
                triggeredBy: "export_pdf",
                focusProduct: "com.app.pro"
            )
        }
    }
}
```

## Product Configuration

### Configuration with StoreKitConfiguration

```swift
let config = StoreKitConfiguration()
    .withPurchases(products: [
        Product("com.app.basic", features: [Feature.removeAds]),
        Product("com.app.pro", features: [Feature.removeAds, Feature.cloudSync])
    ])
    .withPaywall { context in
        CustomPaywallView(context: context)
    }
    .withTerms {
        TermsView()
    }
    .withPrivacy {
        PrivacyView()
    }

ContentView()
    .withConfiguration(config)
```

### Environment-Based Configuration

```swift
struct ContentView: View {
    var body: some View {
        MainAppView()
            .withPurchases(products: products)
            .withPaywall { context in
                if UIDevice.current.userInterfaceIdiom == .pad {
                    iPadPaywallView(context: context)
                } else {
                    iPhonePaywallView(context: context)
                }
            }
    }

    private var products: [ProductConfig<AppFeature>] {
        #if DEBUG
        return [
            Product("com.app.test", features: AppFeature.allCases)
        ]
        #else
        return [
            Product("com.app.basic", features: [.removeAds]),
            Product("com.app.pro", features: AppFeature.allCases)
        ]
        #endif
    }
}
```

## UI Customization

### Custom Purchase Buttons

```swift
struct PurchaseButton: View {
    let product: Product
    @State private var isPurchasing = false

    var body: some View {
        Button(action: purchase) {
            HStack {
                if isPurchasing {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Text("Get \\(product.displayName)")
                    Spacer()
                    Text(product.displayPrice)
                        .fontWeight(.bold)
                }
            }
            .foregroundColor(.white)
            .padding()
            .background(Color.blue)
            .cornerRadius(12)
        }
        .disabled(isPurchasing)
    }

    private func purchase() {
        isPurchasing = true
        Task {
            await InAppKit.shared.purchase(product)
            isPurchasing = false
        }
    }
}
```

### Custom Terms and Privacy

```swift
ContentView()
    .withPurchases(products: [...])
    .withTerms {
        VStack {
            Text("Terms of Service")
                .font(.title2)
                .fontWeight(.bold)

            ScrollView {
                Text(termsText)
                    .font(.body)
            }

            Button("Accept") {
                // Handle acceptance
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    .withPrivacy {
        VStack {
            Text("Privacy Policy")
                .font(.title2)
                .fontWeight(.bold)

            ScrollView {
                Text(privacyText)
                    .font(.body)
            }

            Button("Understood") {
                // Handle acknowledgment
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
```

### Custom Paywall Header and Features

Customize the header section and features section of the default paywall to match your app's branding.

```swift
// Custom header with different icon and colors
ContentView()
    .withPurchases(products: [...])
    .withPaywallHeader {
        PaywallHeader(
            icon: .system("sparkles"),
            title: "Go Premium",
            subtitle: "Transform your experience with powerful features",
            iconColor: .purple,
            backgroundColor: .purple.opacity(0.15)
        )
    }
    .withPaywallFeatures {
        PaywallFeatures(
            title: "Premium Benefits",
            features: [
                PaywallFeature(
                    icon: .system("wand.and.stars"),
                    title: "AI-Powered Features",
                    subtitle: "Smart automation and intelligent suggestions",
                    iconColor: .purple
                ),
                PaywallFeature(
                    icon: .asset("cloud-sync-icon"),  // Using custom asset
                    title: "Cloud Sync",
                    subtitle: "Seamless sync across all your devices",
                    iconColor: .blue
                ),
                PaywallFeature(
                    icon: .system("chart.line.uptrend.xyaxis"),
                    title: "Advanced Analytics",
                    subtitle: "Detailed insights and performance metrics",
                    iconColor: .green
                ),
                PaywallFeature(
                    icon: .custom(Image("priority-badge").renderingMode(.template)),
                    title: "Priority Support",
                    subtitle: "Get expert help within 24 hours",
                    iconColor: .orange
                )
            ]
        )
    }
```

Or use the convenience methods for simpler customization:

```swift
// System icon (default)
ContentView()
    .withPurchases(products: [...])
    .withPaywallHeader(
        systemIcon: "crown.fill",
        title: "Unlock Pro",
        subtitle: "Get access to all premium features",
        iconColor: .gold
    )

// Asset icon
ContentView()
    .withPurchases(products: [...])
    .withPaywallHeader(
        assetIcon: "premium-crown",
        title: "Unlock Pro",
        subtitle: "Get access to all premium features",
        iconColor: .gold
    )

// PaywallIcon enum
ContentView()
    .withPurchases(products: [...])
    .withPaywallHeader(
        icon: .asset("premium-crown"),
        title: "Unlock Pro",
        subtitle: "Get access to all premium features",
        iconColor: .gold
    )
    .withPaywallFeatures(
        title: "What You Get",
        features: PaywallFeature.defaultFeatures
    )
```

### Icon Types

PaywallIcon supports three different icon types:

```swift
// System icons (SF Symbols)
PaywallFeature(icon: .system("star.fill"), title: "Premium", subtitle: "...")

// Asset images from your app bundle
PaywallFeature(icon: .asset("premium-icon"), title: "Premium", subtitle: "...")

// Custom images with full control
PaywallFeature(
    icon: .custom(
        Image("custom-icon")
            .renderingMode(.template)
            .resizable()
    ),
    title: "Premium",
    subtitle: "..."
)

// Convenience initializers for backward compatibility
PaywallFeature(systemIcon: "star.fill", title: "Premium", subtitle: "...")
PaywallFeature(assetIcon: "premium-icon", title: "Premium", subtitle: "...")
```

### Custom Paywall Components

Build completely custom sections using the components:

```swift
ContentView()
    .withPurchases(products: [...])
    .withPaywallHeader {
        VStack(spacing: 20) {
            // Custom animated header
            Lottie(name: "premium-animation")
                .frame(height: 120)

            VStack(spacing: 8) {
                Text("Welcome to Premium")
                    .font(.largeTitle)
                    .fontWeight(.black)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                Text("Experience the full potential of our app")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    .withPaywallFeatures {
        VStack(spacing: 24) {
            Text("Exclusive Features")
                .font(.title2)
                .fontWeight(.bold)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(customFeatures, id: \.id) { feature in
                    FeatureCard(feature: feature)
                }
            }
        }
    }
```

## Advanced Configuration

### Feature-Specific Paywalls

```swift
struct AdvancedView: View {
    var body: some View {
        VStack {
            Button("Export PDF") {
                exportPDF()
            }
            .requiresPurchase(
                Feature.exportPDF,
                paywall: { context in
                    ExportPaywallView(context: context)
                }
            )

            Button("Cloud Sync") {
                syncToCloud()
            }
            .requiresPurchase(
                Feature.cloudSync,
                paywall: { context in
                    CloudSyncPaywallView(context: context)
                }
            )
        }
    }
}
```

### Dynamic Product Configuration

```swift
struct DynamicConfigView: View {
    @State private var products: [ProductConfig<AppFeature>] = []

    var body: some View {
        ContentView()
            .withPurchases(products: products)
            .onAppear {
                loadProducts()
            }
    }

    private func loadProducts() {
        // Load from remote config, A/B test, etc.
        if UserDefaults.standard.bool(forKey: "showPremiumTier") {
            products = [
                Product("com.app.basic", features: [.removeAds]),
                Product("com.app.pro", features: [.removeAds, .cloudSync]),
                Product("com.app.premium", features: AppFeature.allCases)
            ]
        } else {
            products = [
                Product("com.app.pro", features: AppFeature.allCases)
            ]
        }
    }
}
```

### Conditional Features

```swift
struct ConditionalFeatureView: View {
    @State private var userTier: UserTier = .free

    var body: some View {
        VStack {
            switch userTier {
            case .free:
                FreeContentView()
            case .basic:
                BasicContentView()
            case .pro:
                ProContentView()
            case .premium:
                PremiumContentView()
            }
        }
        .onAppear {
            updateUserTier()
        }
    }

    private func updateUserTier() {
        if InAppKit.shared.hasAccess(to: "com.app.premium") {
            userTier = .premium
        } else if InAppKit.shared.hasAccess(to: "com.app.pro") {
            userTier = .pro
        } else if InAppKit.shared.hasAccess(to: "com.app.basic") {
            userTier = .basic
        } else {
            userTier = .free
        }
    }
}
```

### Testing and Debugging

```swift
#if DEBUG
struct DebugPaywallView: View {
    let context: PaywallContext

    var body: some View {
        VStack {
            Text("DEBUG: Paywall")
                .foregroundColor(.red)

            Text("Triggered by: \\(context.triggeredBy ?? "unknown")")

            ForEach(context.availableProducts, id: \\.id) { product in
                VStack {
                    Text(product.id)
                    Text("Price: \\(product.displayPrice)")
                    Button("Simulate Purchase") {
                        // Simulate purchase for testing
                        UserDefaults.standard.set(true, forKey: "purchased_\\(product.id)")
                    }
                }
                .padding()
                .border(Color.gray)
            }
        }
    }
}
#endif
```

---

**Next Steps:**
- **[API Reference →](api-reference.md)** Complete technical documentation
- **[Monetization Patterns →](monetization-patterns.md)** Choose the right strategy
- **[Getting Started →](getting-started.md)** Learn the basics