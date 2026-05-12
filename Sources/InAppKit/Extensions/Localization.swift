//
//  Localization.swift
//  InAppKit
//
//  Localization support utilities
//

import Foundation

// MARK: - Localization Support

private func lookup(_ key: String) -> String? {
    let appHit = NSLocalizedString(key, bundle: .main, value: "\u{0}", comment: "")
    if appHit != "\u{0}" { return appHit }

    let libHit = NSLocalizedString(key, bundle: .module, value: "\u{0}", comment: "")
    if libHit != "\u{0}" { return libHit }

    return nil
}

func L(_ key: String, comment: String = "") -> String {
    lookup(key) ?? key
}

func L(_ key: String, _ arguments: CVarArg...) -> String {
    String(format: lookup(key) ?? key, arguments: arguments)
}

// MARK: - String Localization Extension

public extension String {
    /// Localize string with optional fallback value.
    /// Looks up in the host app bundle first (for overrides), then in InAppKit's
    /// bundled resources, finally falling back to the provided default.
    func localized(fallback: String? = nil) -> String {
        lookup(self) ?? fallback ?? self
    }

    /// Localize string with arguments and optional fallback.
    func localized(_ arguments: CVarArg..., fallback: String? = nil) -> String {
        let format = lookup(self) ?? fallback ?? self
        return String(format: format, arguments: arguments)
    }
}
