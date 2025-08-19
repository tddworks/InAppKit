//
//  ViewExtensions.swift
//  InAppKit
//
//  View extension utilities
//

import SwiftUI

public extension View {
    /// Automatically adds terms and privacy footer to any view
    func withTermsAndPrivacy() -> some View {
        VStack(spacing: 0) {
            self
            TermsPrivacyFooter()
        }
    }
    
    /// Automatically adds terms and privacy footer with custom spacing
    func withTermsAndPrivacy(spacing: CGFloat) -> some View {
        VStack(spacing: spacing) {
            self
            TermsPrivacyFooter()
        }
    }
}
