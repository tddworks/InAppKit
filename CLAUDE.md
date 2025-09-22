# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Building and Testing
- **Build**: `swift build`
- **Test**: `swift test`
- **Single test**: Use test explorer in Xcode or target specific test methods in Swift Testing
- **Swift version**: `swift --version` (requires Swift 6.1+)

### Xcode Development
- Open `InAppKit.xcodeproj` or `Workspace.xcworkspace` for full IDE experience
- Project supports iOS 17+, macOS 15+, watchOS 10+, tvOS 17+

## Architecture Overview

InAppKit is a SwiftUI library that simplifies in-app purchases through a declarative API. The architecture follows these key patterns:

### Core Components

1. **InAppKit (Singleton)** (`Sources/InAppKit/Core/InAppKit.swift`)
   - `@MainActor @Observable` singleton managing all purchase state
   - Handles StoreKit integration, transaction validation, and feature access
   - Maps features to products and maintains purchase entitlements

2. **Product Configuration System** (`Sources/InAppKit/Configuration/`)
   - `ProductConfig<T>` - Type-safe product definitions with features
   - `StoreKitConfiguration` - Fluent API for app setup
   - `PaywallContext` - Context object for paywall presentations

3. **Feature System** (`Sources/InAppKit/Core/Feature.swift`)
   - `AppFeature` protocol for type-safe feature definitions
   - Features map to product IDs through configuration
   - Supports both enum-based and string-based feature definitions

### Key Patterns

**Fluent Configuration API**: The library uses method chaining for setup:
```swift
ContentView()
    .withPurchases(products: [
        Product("com.app.pro", features: AppFeature.allCases)
    ])
    .withPaywall { context in PaywallView(products: context.availableProducts) }
```

**View Modifiers**: Main integration points are SwiftUI view modifiers:
- `.withPurchases()` - Initializes purchase system
- `.requiresPurchase()` - Gates content behind purchases
- `.withPaywall()` - Custom paywall presentation

**Type Safety**: Features are defined as enums conforming to `AppFeature` protocol for compile-time safety.

### UI Architecture

- **Component-based**: Reusable UI components in `Sources/InAppKit/UI/Components/`
- **Modifier-driven**: Purchase gating through view modifiers in `Sources/InAppKit/Modifiers/`
- **Localization**: Full i18n support with fallback strings in `Sources/InAppKit/Extensions/Localization.swift`

### StoreKit Integration

- **Observable Pattern**: Uses Swift's `@Observable` for state management
- **Transaction Handling**: Automatic verification and entitlement updates
- **Background Listening**: Persistent transaction listener for receipt updates

## Testing Approach

Uses Swift Testing framework with `@testable import InAppKit`:
- Feature configuration testing
- Product mapping validation
- Fluent API chain testing
- Mock purchase simulation in DEBUG builds

The test suite focuses on configuration validation and API usability rather than StoreKit integration (which requires App Store Connect setup).

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