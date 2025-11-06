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
| `paywall.purchase.purchased` | "Purchased" |
| `paywall.purchase.subscribe` | "Subscribe" |
| `paywall.purchase.change_plan` | "Change Plan" |
| `paywall.purchase.buy` | "Buy" |
| `paywall.purchase.purchase` | "Purchase" |
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

## Introductory Offers

| Key | Default Value |
|-----|---------------|
| `purchase.intro.free_trial` | "%@ free trial" (formatted with duration, e.g., "7 days free trial") |
| `purchase.intro.pay_as_you_go_single` | "%@ for first %@" (formatted with price, period) |
| `purchase.intro.pay_as_you_go_multiple` | "%@ for %@ %@s" (formatted with price, count, period) |
| `purchase.intro.pay_upfront_single` | "%@ for first %@" (formatted with price, period) |
| `purchase.intro.pay_upfront_multiple` | "%@ for first %@ %@s" (formatted with price, count, period) |

## Period Text - Billing Style

| Key | Default Value |
|-----|---------------|
| `purchase.period.billing.daily` | "Daily" |
| `purchase.period.billing.weekly` | "Weekly" |
| `purchase.period.billing.monthly` | "Monthly" |
| `purchase.period.billing.annual` | "Annual" |
| `purchase.period.billing.day_multiple` | "%@-day" (formatted with count) |
| `purchase.period.billing.week_multiple` | "%@-week" (formatted with count) |
| `purchase.period.billing.month_multiple` | "%@-month" (formatted with count) |
| `purchase.period.billing.year_multiple` | "%@-year" (formatted with count) |
| `purchase.period.billing.periodic` | "Periodic" |

## Period Text - Descriptive Style

| Key | Default Value |
|-----|---------------|
| `purchase.period.descriptive.daily` | "Daily" |
| `purchase.period.descriptive.weekly` | "Weekly" |
| `purchase.period.descriptive.monthly` | "Monthly" |
| `purchase.period.descriptive.yearly` | "Yearly" |
| `purchase.period.descriptive.day_multiple` | "Every %@ days" (formatted with count) |
| `purchase.period.descriptive.week_multiple` | "Every %@ weeks" (formatted with count) |
| `purchase.period.descriptive.month_multiple` | "Every %@ months" (formatted with count) |
| `purchase.period.descriptive.year_multiple` | "Every %@ years" (formatted with count) |
| `purchase.period.descriptive.periodic` | "Periodic" |

## Duration Text

Used for introductory offer descriptions to show specific durations (e.g., "7 days free trial" instead of "Weekly free trial").

| Key | Default Value |
|-----|---------------|
| `purchase.duration.day_single` | "1 day" |
| `purchase.duration.day_multiple` | "%@ days" (formatted with count) |
| `purchase.duration.week_single` | "1 week" |
| `purchase.duration.week_multiple` | "%@ weeks" (formatted with count) |
| `purchase.duration.month_single` | "1 month" |
| `purchase.duration.month_multiple` | "%@ months" (formatted with count) |
| `purchase.duration.year_single` | "1 year" |
| `purchase.duration.year_multiple` | "%@ years" (formatted with count) |
| `purchase.duration.unknown` | "%@ periods" (formatted with count) |

## Relative Discounts

Automatically calculated discounts when using `.withRelativeDiscount(comparedTo:)` API.

| Key | Default Value |
|-----|---------------|
| `discount.percentage` | "Save %@%" (formatted with percentage, e.g., "Save 31%") |
| `discount.amount` | "Save %@" (formatted with currency amount, e.g., "Save $44") |
| `discount.free_time` | "%@ months free" (formatted with month count, e.g., "2 months free") |

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

// Purchase periods
"purchase.period.billing.monthly" = "Monthly";
"purchase.period.billing.annual" = "Annual";
"purchase.period.descriptive.monthly" = "Monthly";

// Duration text (for intro offers)
"purchase.duration.day_single" = "1 day";
"purchase.duration.day_multiple" = "%@ days";
"purchase.duration.week_single" = "1 week";
"purchase.duration.month_single" = "1 month";

// Relative discounts
"discount.percentage" = "Save %@%";
"discount.amount" = "Save %@";
"discount.free_time" = "%@ months free";

// Introductory offers
"purchase.intro.free_trial" = "%@ free trial";
"purchase.intro.pay_as_you_go_multiple" = "%@ for %@ %@s";
// ... add more keys as needed

// Spanish (es.lproj/Localizable.strings)
"paywall.header.title" = "Actualizar a Pro";
"paywall.header.subtitle" = "Desbloquea funciones avanzadas y soporte premium";
"paywall.features.title" = "Qué Incluye";

// Períodos de compra
"purchase.period.billing.monthly" = "Mensual";
"purchase.period.billing.annual" = "Anual";
"purchase.period.descriptive.monthly" = "Mensual";

// Texto de duración (para ofertas introductorias)
"purchase.duration.day_single" = "1 día";
"purchase.duration.day_multiple" = "%@ días";
"purchase.duration.week_single" = "1 semana";
"purchase.duration.month_single" = "1 mes";

// Descuentos relativos
"discount.percentage" = "Ahorra %@%";
"discount.amount" = "Ahorra %@";
"discount.free_time" = "%@ meses gratis";

// Ofertas introductorias
"purchase.intro.free_trial" = "%@ de prueba gratis";
"purchase.intro.pay_as_you_go_multiple" = "%@ por %@ %@s";
// ... add more keys as needed
```

## Benefits

- **Fallback Safety**: Always shows meaningful text even without localization files
- **Flexible**: Only localize the keys you need, others use English defaults
- **Maintainable**: Clear key naming convention with dot notation
- **Developer Friendly**: Easy to add new languages incrementally