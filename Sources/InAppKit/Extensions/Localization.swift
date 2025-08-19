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
