# InAppKit Localization Keys

This document lists all localization keys used in InAppKit with their default fallback values.

## Usage

All strings support the `.localized(fallback:)` pattern:

```swift
"paywall.header.title".localized(fallback: "Upgrade to Pro")
```

## Paywall Header

| Key | Default Value |
|-----|---------------|
| `paywall.header.title` | "Upgrade to Pro" |
| `paywall.header.subtitle` | "Unlock advanced features and premium support" |

## Paywall Features

| Key | Default Value |
|-----|---------------|
| `paywall.features.title` | "What's Included" |
| `paywall.feature.premium.title` | "Premium Features" |
| `paywall.feature.premium.subtitle` | "Access to all advanced functionality" |
| `paywall.feature.support.title` | "Priority Support" |
| `paywall.feature.support.subtitle` | "Get help when you need it most" |
| `paywall.feature.updates.title` | "Regular Updates" |
| `paywall.feature.updates.subtitle` | "New features and improvements" |
| `paywall.feature.lifetime.title` | "Lifetime Access" |
| `paywall.feature.lifetime.subtitle` | "One-time purchase, yours forever" |

## Paywall Actions

| Key | Default Value |
|-----|---------------|
| `paywall.loading` | "Loading products..." |
| `paywall.purchase.button` | "Purchase %@" (formatted with price) |
| `paywall.purchase.processing` | "Processing..." |
| `paywall.restore.button` | "Restore Purchases" |
| `paywall.restore.restoring` | "Restoring..." |
| `paywall.restore.title` | "Restore Status" |
| `paywall.restore.ok` | "OK" |
| `paywall.restore.success` | "Purchases restored successfully!" |
| `paywall.restore.none` | "No previous purchases found." |

## Terms and Privacy

| Key | Default Value |
|-----|---------------|
| `paywall.terms` | "Terms" |
| `paywall.privacy` | "Privacy" |

## Terms View

| Key | Default Value |
|-----|---------------|
| `terms.title` | "Terms of Service" |
| `terms.content` | "By using this app, you agree to our terms of service." |
| `terms.default.note` | "This is a default terms view. Configure custom terms using the StoreKit customization API." |
| `terms.navigation.title` | "Terms" |

## Privacy View

| Key | Default Value |
|-----|---------------|
| `privacy.title` | "Privacy Policy" |
| `privacy.content` | "We respect your privacy and are committed to protecting your personal information." |
| `privacy.default.note` | "This is a default privacy view. Configure custom privacy policy using the StoreKit customization API." |
| `privacy.navigation.title` | "Privacy" |

## Purchase Types

| Key | Default Value |
|-----|---------------|
| `purchase.subscription.description` | "Subscription • Auto-renewable" |
| `purchase.lifetime.description` | "One-time purchase • Lifetime access" |
| `purchase.consumable.description` | "Consumable purchase" |
| `purchase.unknown.description` | "In-app purchase" |
| `purchase.subscription.type` | "Subscription" |
| `purchase.lifetime.type` | "Lifetime" |
| `purchase.consumable.type` | "Per use" |
| `purchase.unknown.type` | "Purchase" |

## Common

| Key | Default Value |
|-----|---------------|
| `common.close` | "Close" |

## Localization File Example

Create a `Localizable.strings` file in your app bundle:

```strings
// English (en.lproj/Localizable.strings)
"paywall.header.title" = "Upgrade to Pro";
"paywall.header.subtitle" = "Unlock advanced features and premium support";
"paywall.features.title" = "What's Included";
// ... add more keys as needed

// Spanish (es.lproj/Localizable.strings)
"paywall.header.title" = "Actualizar a Pro";
"paywall.header.subtitle" = "Desbloquea funciones avanzadas y soporte premium";
"paywall.features.title" = "Qué Incluye";
// ... add more keys as needed
```

## Benefits

- **Fallback Safety**: Always shows meaningful text even without localization files
- **Flexible**: Only localize the keys you need, others use English defaults
- **Maintainable**: Clear key naming convention with dot notation
- **Developer Friendly**: Easy to add new languages incrementally