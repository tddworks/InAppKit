//
//  Localization.swift
//  InAppKit
//
//  Localization support utilities
//

import Foundation

// MARK: - Localization Support

func L(_ key: String, comment: String = "") -> String {
    return NSLocalizedString(key, bundle: Bundle.main, comment: comment)
}

func L(_ key: String, _ arguments: CVarArg...) -> String {
    let format = NSLocalizedString(key, bundle: Bundle.main, comment: "")
    return String(format: format, arguments: arguments)
}

// MARK: - String Localization Extension

public extension String {
    /// Localize string with optional fallback value
    /// - Parameter fallback: Default value to use if localization key is not found
    /// - Returns: Localized string or fallback if localization failed
    func localized(fallback: String? = nil) -> String {
        let localized = NSLocalizedString(self, bundle: Bundle.main, comment: "")

        // If localization failed (returns the key itself), use fallback
        if localized == self, let fallback = fallback {
            return fallback
        }

        return localized
    }

    /// Localize string with arguments and optional fallback
    /// - Parameters:
    ///   - arguments: Arguments for string formatting
    ///   - fallback: Default value to use if localization key is not found
    /// - Returns: Formatted localized string or fallback
    func localized(_ arguments: CVarArg..., fallback: String? = nil) -> String {
        let format = NSLocalizedString(self, bundle: Bundle.main, comment: "")

        // If localization failed and fallback provided, use fallback
        if format == self, let fallback = fallback {
            return String(format: fallback, arguments: arguments)
        }

        return String(format: format, arguments: arguments)
    }
}
