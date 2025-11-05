//
//  WebView.swift
//  InAppKit
//
//  Web view components for displaying URLs in-app
//

import SwiftUI

#if canImport(SafariServices)
import SafariServices
#endif

// MARK: - Safari View Controller

#if canImport(UIKit) && canImport(SafariServices)
import UIKit

public class WebViewController: SFSafariViewController {
    public init(url: URL) {
        let configuration = SFSafariViewController.Configuration()
        super.init(url: url, configuration: configuration)

        modalPresentationStyle = .currentContext
        preferredControlTintColor = .label
    }
}

// MARK: - SwiftUI Wrapper

struct WebView: UIViewControllerRepresentable {
    private let url: URL

    init(url: URL) {
        self.url = url
    }

    func makeUIViewController(context: Context) -> WebViewController {
        return WebViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: WebViewController, context: Context) {}
}
#endif

// MARK: - macOS Fallback

#if canImport(AppKit)
import AppKit

struct WebView: View {
    private let url: URL
    @Environment(\.dismiss) private var dismiss

    init(url: URL) {
        self.url = url
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Image(systemName: "safari")
                    .font(.system(size: 48))
                    .foregroundColor(.secondary)

                Text("Open in Browser")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(url.absoluteString)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Button("Open in Safari") {
                    NSWorkspace.shared.open(url)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)

                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .navigationTitle("Open Link")
        }
        .frame(idealWidth: 400, idealHeight: 300)
    }
}
#endif
