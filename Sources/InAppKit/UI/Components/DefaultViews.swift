//
//  DefaultViews.swift
//  InAppKit
//
//  Default terms and privacy views
//

import SwiftUI

// MARK: - Default Terms and Privacy Views

struct DefaultTermsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("terms.title".localized(fallback: "Terms of Service"))
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("terms.content".localized(fallback: "By using this app, you agree to our terms of service."))
                        .font(.body)
                    
                    Text("terms.default.note".localized(fallback: "This is a default terms view. Configure custom terms using the StoreKit customization API."))
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            .navigationTitle("terms.navigation.title".localized(fallback: "Terms"))
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("common.close".localized(fallback: "Close")) { dismiss() }
                }
            }
        }
        .frame(width: 440, height: 600)
    }
}

struct DefaultPrivacyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("privacy.title".localized(fallback: "Privacy Policy"))
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("privacy.content".localized(fallback: "We respect your privacy and are committed to protecting your personal information."))
                        .font(.body)
                    
                    Text("privacy.default.note".localized(fallback: "This is a default privacy view. Configure custom privacy policy using the StoreKit customization API."))
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            .navigationTitle("privacy.navigation.title".localized(fallback: "Privacy"))
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("common.close".localized(fallback: "Close")) { dismiss() }
                }
            }
        }
        .frame(width: 440, height: 600)
    }
}
