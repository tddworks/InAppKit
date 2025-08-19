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
                    Text("Terms of Service")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("By using this app, you agree to our terms of service.")
                        .font(.body)
                    
                    Text("This is a default terms view. Configure custom terms using the StoreKit customization API.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            .navigationTitle("Terms")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Close") { dismiss() }
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
                    Text("Privacy Policy")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("We respect your privacy and are committed to protecting your personal information.")
                        .font(.body)
                    
                    Text("This is a default privacy view. Configure custom privacy policy using the StoreKit customization API.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            .navigationTitle("Privacy")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .frame(width: 440, height: 600)
    }
}
