# InAppKit Documentation

Welcome to the InAppKit documentation! Follow this learning path for the best experience.

## 🚀 Learning Path

### 1. **[Getting Started](getting-started.md)** *(10 minutes)*
Learn core concepts and build your first premium feature
- Understanding Products, Features, and Paywalls
- Product API Guidelines
- Step-by-step tutorial
- Common patterns

### 2. **[Monetization Patterns](monetization-patterns.md)** *(15 minutes)*
Choose the right strategy for your app
- Freemium vs Premium vs Subscription
- Pattern-specific examples
- Decision framework
- Platform-specific recommendations

### 3. **[Customization Guide](customization.md)** *(20 minutes)*
Make InAppKit match your app's design
- Marketing-enhanced products
- Custom paywalls and UI
- Advanced configuration
- Testing and debugging

### 4. **[Localization Guide](localization-keys.md)** *(5 minutes)*
Internationalize your app with built-in localization support
- Complete localization keys reference
- Fallback safety for all text
- Multi-language setup examples
- Best practices for global apps

### 5. **[API Reference](api-reference.md)** *(Reference)*
Complete technical documentation
- All Product functions
- Configuration options
- Type references
- Troubleshooting guide

## 📋 Quick Reference

### Essential APIs
```swift
// Basic setup
ContentView()
    .withPurchases("com.yourapp.pro")

// Feature gating
Text("Premium Content")
    .requiresPurchase()

// Check access
InAppKit.shared.hasAccess(to: Feature.cloudSync)
```

### Product Creation Patterns
```swift
// No features
Product("com.app.basic")

// With features
Product("com.app.pro", features: [Feature.sync, Feature.export])

// All features
Product("com.app.premium", features: Feature.allCases)
```

## 🎯 By Use Case

- **New to InAppKit?** → Start with [Getting Started](getting-started.md)
- **Choosing monetization strategy?** → See [Monetization Patterns](monetization-patterns.md)
- **Customizing UI?** → Check [Customization Guide](customization.md)
- **Supporting multiple languages?** → See [Localization Guide](localization-keys.md)
- **Need specific API?** → Reference [API Documentation](api-reference.md)
- **Having issues?** → Try [Troubleshooting](api-reference.md#troubleshooting)

## 🤝 Community & Support

- **Issues**: [GitHub Issues](https://github.com/tddworks/InAppKit/issues)
- **Discussions**: [GitHub Discussions](https://github.com/tddworks/InAppKit/discussions)
- **Main README**: [../README.md](../README.md)

---

**Ready to start?** → **[Begin with Getting Started →](getting-started.md)**