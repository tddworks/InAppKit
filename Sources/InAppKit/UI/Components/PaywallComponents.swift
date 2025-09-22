//
//  PaywallComponents.swift
//  InAppKit
//
//  Reusable paywall customization components
//

import SwiftUI

// MARK: - PaywallIcon

/// Icon type for paywall components supporting system icons, asset images, and custom images
public enum PaywallIcon: Sendable {
    case system(String)
    case asset(String)
    case custom(Image)

    public var image: Image {
        switch self {
        case .system(let name):
            return Image(systemName: name)
        case .asset(let name):
            return Image(name)
        case .custom(let image):
            return image
        }
    }
}

// MARK: - Paywall Header Components

/// Customizable paywall header with icon, title, and subtitle
public struct PaywallHeader: View {
    let icon: PaywallIcon
    let title: String
    let subtitle: String
    let iconColor: Color
    let backgroundColor: Color

    public init(
        icon: PaywallIcon = .system("crown.fill"),
        title: String = "Upgrade to Pro",
        subtitle: String = "Unlock advanced features and premium support",
        iconColor: Color = .blue,
        backgroundColor: Color = Color.blue.opacity(0.2)
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.iconColor = iconColor
        self.backgroundColor = backgroundColor
    }

    // Convenience initializers for backward compatibility
    public init(
        systemIcon: String,
        title: String = "Upgrade to Pro",
        subtitle: String = "Unlock advanced features and premium support",
        iconColor: Color = .blue,
        backgroundColor: Color = Color.blue.opacity(0.2)
    ) {
        self.init(
            icon: .system(systemIcon),
            title: title,
            subtitle: subtitle,
            iconColor: iconColor,
            backgroundColor: backgroundColor
        )
    }

    public init(
        assetIcon: String,
        title: String = "Upgrade to Pro",
        subtitle: String = "Unlock advanced features and premium support",
        iconColor: Color = .blue,
        backgroundColor: Color = Color.blue.opacity(0.2)
    ) {
        self.init(
            icon: .asset(assetIcon),
            title: title,
            subtitle: subtitle,
            iconColor: iconColor,
            backgroundColor: backgroundColor
        )
    }

    public var body: some View {
        VStack(spacing: 16) {
            // Premium icon with gradient
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [backgroundColor, backgroundColor.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)

                icon.image
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [iconColor, iconColor.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)

                Text(subtitle)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
        }
    }
}

// MARK: - Paywall Features Components

/// Individual feature row component
public struct PaywallFeatureRow: View {
    let icon: PaywallIcon
    let title: String
    let subtitle: String
    let iconColor: Color

    public init(
        icon: PaywallIcon,
        title: String,
        subtitle: String,
        iconColor: Color = .blue
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.iconColor = iconColor
    }

    // Convenience initializers
    public init(
        systemIcon: String,
        title: String,
        subtitle: String,
        iconColor: Color = .blue
    ) {
        self.init(
            icon: .system(systemIcon),
            title: title,
            subtitle: subtitle,
            iconColor: iconColor
        )
    }

    public init(
        assetIcon: String,
        title: String,
        subtitle: String,
        iconColor: Color = .blue
    ) {
        self.init(
            icon: .asset(assetIcon),
            title: title,
            subtitle: subtitle,
            iconColor: iconColor
        )
    }

    public var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 44, height: 44)

                icon.image
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(iconColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)

                Text(subtitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.horizontal, 4)
    }
}

/// Customizable features section
public struct PaywallFeatures: View {
    let title: String
    let features: [PaywallFeature]

    public init(
        title: String = "What's Included",
        features: [PaywallFeature]
    ) {
        self.title = title
        self.features = features
    }

    public var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)

            VStack(spacing: 12) {
                ForEach(features, id: \.id) { feature in
                    PaywallFeatureRow(
                        icon: feature.icon,
                        title: feature.title,
                        subtitle: feature.subtitle,
                        iconColor: feature.iconColor
                    )
                }
            }
        }
        .padding(.vertical, 12)
    }
}

// MARK: - PaywallFeature Model

public struct PaywallFeature: Identifiable, Sendable {
    public let id = UUID()
    public let icon: PaywallIcon
    public let title: String
    public let subtitle: String
    public let iconColor: Color

    public init(
        icon: PaywallIcon,
        title: String,
        subtitle: String,
        iconColor: Color = .blue
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.iconColor = iconColor
    }

    // Convenience initializers
    public init(
        systemIcon: String,
        title: String,
        subtitle: String,
        iconColor: Color = .blue
    ) {
        self.init(
            icon: .system(systemIcon),
            title: title,
            subtitle: subtitle,
            iconColor: iconColor
        )
    }

    public init(
        assetIcon: String,
        title: String,
        subtitle: String,
        iconColor: Color = .blue
    ) {
        self.init(
            icon: .asset(assetIcon),
            title: title,
            subtitle: subtitle,
            iconColor: iconColor
        )
    }

    // MARK: - Default Features

    public static let premiumFeatures = PaywallFeature(
        icon: .system("star.fill"),
        title: "Premium Features",
        subtitle: "Access to all advanced functionality"
    )

    public static let prioritySupport = PaywallFeature(
        icon: .system("heart.fill"),
        title: "Priority Support",
        subtitle: "Get help when you need it most"
    )

    public static let regularUpdates = PaywallFeature(
        icon: .system("arrow.clockwise"),
        title: "Regular Updates",
        subtitle: "New features and improvements"
    )

    public static let lifetimeAccess = PaywallFeature(
        icon: .system("checkmark.shield.fill"),
        title: "Lifetime Access",
        subtitle: "One-time purchase, yours forever"
    )

    public static let defaultFeatures: [PaywallFeature] = [
        .premiumFeatures,
        .prioritySupport,
        .regularUpdates,
        .lifetimeAccess
    ]
}

// MARK: - Convenience Extensions

public extension View {
    /// Add a custom paywall header to the chain with system icon
    func withPaywallHeader(
        systemIcon: String = "crown.fill",
        title: String = "Upgrade to Pro",
        subtitle: String = "Unlock advanced features and premium support",
        iconColor: Color = .blue,
        backgroundColor: Color = Color.blue.opacity(0.2)
    ) -> ChainableStoreKitView<Self> {
        let config = StoreKitConfiguration()
        let newConfig = config.withPaywallHeader {
            PaywallHeader(
                icon: .system(systemIcon),
                title: title,
                subtitle: subtitle,
                iconColor: iconColor,
                backgroundColor: backgroundColor
            )
        }
        return ChainableStoreKitView(content: self, config: newConfig)
    }

    /// Add a custom paywall header to the chain with asset icon
    func withPaywallHeader(
        assetIcon: String,
        title: String = "Upgrade to Pro",
        subtitle: String = "Unlock advanced features and premium support",
        iconColor: Color = .blue,
        backgroundColor: Color = Color.blue.opacity(0.2)
    ) -> ChainableStoreKitView<Self> {
        let config = StoreKitConfiguration()
        let newConfig = config.withPaywallHeader {
            PaywallHeader(
                icon: .asset(assetIcon),
                title: title,
                subtitle: subtitle,
                iconColor: iconColor,
                backgroundColor: backgroundColor
            )
        }
        return ChainableStoreKitView(content: self, config: newConfig)
    }

    /// Add a custom paywall header to the chain with PaywallIcon
    func withPaywallHeader(
        icon: PaywallIcon,
        title: String = "Upgrade to Pro",
        subtitle: String = "Unlock advanced features and premium support",
        iconColor: Color = .blue,
        backgroundColor: Color = Color.blue.opacity(0.2)
    ) -> ChainableStoreKitView<Self> {
        let config = StoreKitConfiguration()
        let newConfig = config.withPaywallHeader {
            PaywallHeader(
                icon: icon,
                title: title,
                subtitle: subtitle,
                iconColor: iconColor,
                backgroundColor: backgroundColor
            )
        }
        return ChainableStoreKitView(content: self, config: newConfig)
    }

    /// Add custom paywall features to the chain
    func withPaywallFeatures(
        title: String = "What's Included",
        features: [PaywallFeature]
    ) -> ChainableStoreKitView<Self> {
        let config = StoreKitConfiguration()
        let newConfig = config.withPaywallFeatures {
            PaywallFeatures(title: title, features: features)
        }
        return ChainableStoreKitView(content: self, config: newConfig)
    }
}