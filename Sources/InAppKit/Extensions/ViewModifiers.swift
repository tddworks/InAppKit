//
//  ViewModifiers.swift
//  InAppKit
//
//  Additional platform-specific view modifiers for iOS and macOS compatibility
//

import SwiftUI

// MARK: - Sheet and Presentation Modifiers

public extension View {
    /// Present sheet with platform-appropriate sizing
    @ViewBuilder
    func platformSheet<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        #if canImport(UIKit)
        self.sheet(isPresented: isPresented, content: content)
        #elseif canImport(AppKit)
        self.sheet(isPresented: isPresented) {
            content()
                .frame(
                    maxHeight: 800
                )
        }
        #else
        self.sheet(isPresented: isPresented, content: content)
        #endif
    }

    /// Apply platform-appropriate navigation styling
    @ViewBuilder
    func platformNavigationStyle() -> some View {
        #if canImport(UIKit)
        self
        #elseif canImport(AppKit)
        self.navigationSplitViewStyle(.balanced)
        #else
        self
        #endif
    }
}

// MARK: - Text and Typography Modifiers

public extension View {
    /// Apply platform-appropriate text selection behavior
    @ViewBuilder
    func platformTextSelection() -> some View {
        #if canImport(UIKit)
        self
        #elseif canImport(AppKit)
        self.textSelection(.enabled)
        #else
        self
        #endif
    }
}

// MARK: - Focus and Accessibility Modifiers

public extension View {
    /// Apply platform-appropriate focus handling
    @ViewBuilder
    func platformFocusable(_ isFocusable: Bool = true) -> some View {
        #if canImport(AppKit)
        self.focusable(isFocusable)
        #else
        self
        #endif
    }

    /// Add keyboard shortcuts for macOS
    @ViewBuilder
    func platformKeyboardShortcuts() -> some View {
        #if canImport(AppKit)
        self
            .keyboardShortcut(.cancelAction) // ESC to dismiss
        #else
        self
        #endif
    }
}

// MARK: - Animation and Transition Modifiers

public extension View {
    /// Apply platform-appropriate animations
    @ViewBuilder
    func platformAnimation<V: Equatable>(_ animation: Animation?, value: V) -> some View {
        #if canImport(UIKit)
        self.animation(animation, value: value)
        #elseif canImport(AppKit)
        // macOS prefers more subtle animations
        let macOSAnimation = animation?.speed(1.5)
        self.animation(macOSAnimation, value: value)
        #else
        self.animation(animation, value: value)
        #endif
    }

    /// Apply platform-appropriate scale effects
    @ViewBuilder
    func platformScaleEffect(_ scale: CGFloat) -> some View {
        #if canImport(UIKit)
        self.scaleEffect(scale)
        #elseif canImport(AppKit)
        // Slightly more subtle on macOS
        self.scaleEffect(1.0 + (scale - 1.0) * 0.7)
        #else
        self.scaleEffect(scale)
        #endif
    }
}

// MARK: - Layout Modifiers

public extension View {
    /// Apply platform-appropriate padding
    @ViewBuilder
    func platformPadding(_ edges: Edge.Set = .all, _ length: CGFloat? = nil) -> some View {
        let paddingValue = length ?? PlatformConstants.defaultPadding
        self.padding(edges, paddingValue)
    }

    /// Apply platform-appropriate corner radius
    @ViewBuilder
    func platformCornerRadius(_ radius: CGFloat? = nil) -> some View {
        let cornerRadius = radius ?? PlatformConstants.cornerRadius
        self.cornerRadius(cornerRadius)
    }
}

// MARK: - Window and Container Modifiers

public extension View {
    /// Apply appropriate container background
    @ViewBuilder
    func platformContainer() -> some View {
        #if canImport(UIKit)
        self
            .background(Color.platformGroupedBackground)
        #elseif canImport(AppKit)
        self
            .background(Color.platformBackground)
            .frame(minWidth: 300, minHeight: 200)
        #else
        self
            .background(Color.platformBackground)
        #endif
    }
}

// MARK: - Debug Helpers

#if DEBUG
public extension View {
    /// Debug border for layout testing
    @ViewBuilder
    func debugBorder(_ color: Color = .red, width: CGFloat = 1) -> some View {
        self.border(color, width: width)
    }
}
#endif