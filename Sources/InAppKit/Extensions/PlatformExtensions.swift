//
//  PlatformExtensions.swift
//  InAppKit
//
//  Cross-platform utilities for iOS and macOS compatibility
//

import SwiftUI

#if canImport(UIKit)
import UIKit
public typealias PlatformColor = UIColor
#elseif canImport(AppKit)
import AppKit
public typealias PlatformColor = NSColor
#endif

// MARK: - Platform-Specific Colors

public extension Color {
    /// Background color that adapts to platform
    static var platformBackground: Color {
        #if canImport(UIKit)
        return Color(UIColor.systemBackground)
        #elseif canImport(AppKit)
        return Color(NSColor.windowBackgroundColor)
        #else
        return Color.primary
        #endif
    }

    /// Secondary background color that adapts to platform
    static var platformSecondaryBackground: Color {
        #if canImport(UIKit)
        return Color(UIColor.secondarySystemBackground)
        #elseif canImport(AppKit)
        return Color(NSColor.controlBackgroundColor)
        #else
        return Color.secondary
        #endif
    }

    /// Grouped background color that adapts to platform
    static var platformGroupedBackground: Color {
        #if canImport(UIKit)
        return Color(UIColor.systemGroupedBackground)
        #elseif canImport(AppKit)
        return Color(NSColor.windowBackgroundColor)
        #else
        return Color.primary
        #endif
    }
}

// MARK: - Platform-Specific View Modifiers

public extension View {
    /// Apply platform-appropriate button styling
    @ViewBuilder
    func platformButtonStyle() -> some View {
        #if canImport(UIKit)
        self
        #elseif canImport(AppKit)
        self.buttonStyle(PlainButtonStyle())
        #else
        self
        #endif
    }

    /// Apply platform-appropriate card styling
    @ViewBuilder
    func platformCard(cornerRadius: CGFloat = 12, shadow: Bool = true) -> some View {
        #if canImport(UIKit)
        self
            .background(Color.platformSecondaryBackground)
            .cornerRadius(cornerRadius)
            .shadow(color: shadow ? Color.black.opacity(0.1) : Color.clear, radius: 4, x: 0, y: 2)
        #elseif canImport(AppKit)
        self
            .background(Color.platformSecondaryBackground)
            .cornerRadius(cornerRadius)
            .shadow(color: shadow ? Color.black.opacity(0.15) : Color.clear, radius: 8, x: 0, y: 4)
        #else
        self
        #endif
    }
}

// MARK: - Platform-Specific Layout Helpers

public struct PlatformConstants {
    /// Preferred paywall size for the platform
    public static var paywallSize: CGSize {
        #if canImport(UIKit)
        return CGSize(width: 375, height: 812) // iPhone-like proportions
        #elseif canImport(AppKit)
        return CGSize(width: 520, height: 700) // macOS window size
        #else
        return CGSize(width: 400, height: 600)
        #endif
    }

    /// Maximum paywall width for the platform
    public static var maxPaywallWidth: CGFloat {
        #if canImport(UIKit)
        return .infinity
        #elseif canImport(AppKit)
        return 600
        #else
        return 500
        #endif
    }

    /// Preferred padding for the platform
    public static var defaultPadding: CGFloat {
        #if canImport(UIKit)
        return 16
        #elseif canImport(AppKit)
        return 24
        #else
        return 16
        #endif
    }

    /// Preferred corner radius for the platform
    public static var cornerRadius: CGFloat {
        #if canImport(UIKit)
        return 12
        #elseif canImport(AppKit)
        return 8
        #else
        return 8
        #endif
    }
}

// MARK: - Platform Detection

public struct Platform {
    public static var isIOS: Bool {
        #if canImport(UIKit) && !os(watchOS) && !os(tvOS)
        return true
        #else
        return false
        #endif
    }

    public static var isMacOS: Bool {
        #if canImport(AppKit)
        return true
        #else
        return false
        #endif
    }

    public static var isWatchOS: Bool {
        #if os(watchOS)
        return true
        #else
        return false
        #endif
    }

    public static var isTvOS: Bool {
        #if os(tvOS)
        return true
        #else
        return false
        #endif
    }
}

// MARK: - Interaction Modifiers

public extension View {
    /// Add hover effects on platforms that support it
    @ViewBuilder
    func platformHoverEffect() -> some View {
        #if canImport(AppKit)
        self.onHover { hovering in
            // macOS hover state handled by system
        }
        #else
        self
        #endif
    }

    /// Handle platform-appropriate tap/click gestures
    @ViewBuilder
    func platformTapGesture(action: @escaping () -> Void) -> some View {
        self.onTapGesture {
            action()
        }
    }
}