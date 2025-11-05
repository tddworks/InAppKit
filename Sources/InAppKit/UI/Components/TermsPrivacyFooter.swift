//
//  TermsPrivacyFooter.swift
//  InAppKit
//
//  Terms and privacy footer components
//

import SwiftUI

// MARK: - Terms and Privacy Components

public struct TermsPrivacyFooter: View {
    @Environment(\.termsBuilder) private var termsBuilder
    @Environment(\.privacyBuilder) private var privacyBuilder
    @Environment(\.termsURL) private var termsURL
    @Environment(\.privacyURL) private var privacyURL
    @Environment(\.openURL) private var openURL
    @State private var showTerms = false
    @State private var showPrivacy = false

    public init() {}

    public var body: some View {
        HStack(spacing: 4) {
            Button("paywall.terms".localized(fallback: "Terms")) {
                if let url = termsURL {
                    openURL(url)
                } else {
                    showTerms = true
                }
            }
            .font(.system(size: 11, weight: .regular))
            .foregroundColor(.secondary)
            .buttonStyle(PlainButtonStyle())

            Text("•")
                .font(.system(size: 11))
                .foregroundColor(.secondary.opacity(0.6))

            Button("paywall.privacy".localized(fallback: "Privacy")) {
                if let url = privacyURL {
                    openURL(url)
                } else {
                    showPrivacy = true
                }
            }
            .font(.system(size: 11, weight: .regular))
            .foregroundColor(.secondary)
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 8)
        .sheet(isPresented: $showTerms) {
            if let customTerms = termsBuilder {
                customTerms()
            } else {
                DefaultTermsView()
            }
        }
        .sheet(isPresented: $showPrivacy) {
            if let customPrivacy = privacyBuilder {
                customPrivacy()
            } else {
                DefaultPrivacyView()
            }
        }
    }
}

// MARK: - Paywall Container

public struct PaywallContainer<Content: View>: View {
    let content: Content
    let showFooter: Bool
    
    public init(showFooter: Bool = true, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.showFooter = showFooter
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            content
            
            if showFooter {
                TermsPrivacyFooter()
            }
        }
    }
}

// MARK: - Auto Paywall Wrapper

struct AutoPaywallWrapper<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .overlay(alignment: .bottom) {
                // Always show footer as overlay at bottom - use custom views if configured, defaults otherwise
                TermsPrivacyFooter()
            }
    }
}

// MARK: - Individual Button Components

public struct TermsButton: View {
    let title: String
    @Environment(\.termsBuilder) private var termsBuilder
    @Environment(\.termsURL) private var termsURL
    @Environment(\.openURL) private var openURL
    @State private var showTerms = false

    public init(_ title: String = "Terms") {
        self.title = title
    }

    public var body: some View {
        Button(title) {
            if let url = termsURL {
                openURL(url)
            } else {
                showTerms = true
            }
        }
        .sheet(isPresented: $showTerms) {
            if let customTerms = termsBuilder {
                customTerms()
            } else {
                DefaultTermsView()
            }
        }
    }
}

public struct PrivacyButton: View {
    let title: String
    @Environment(\.privacyBuilder) private var privacyBuilder
    @Environment(\.privacyURL) private var privacyURL
    @Environment(\.openURL) private var openURL
    @State private var showPrivacy = false

    public init(_ title: String = "Privacy") {
        self.title = title
    }

    public var body: some View {
        Button(title) {
            if let url = privacyURL {
                openURL(url)
            } else {
                showPrivacy = true
            }
        }
        .sheet(isPresented: $showPrivacy) {
            if let customPrivacy = privacyBuilder {
                customPrivacy()
            } else {
                DefaultPrivacyView()
            }
        }
    }
}
