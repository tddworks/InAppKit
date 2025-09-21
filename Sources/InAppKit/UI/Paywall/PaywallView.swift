//
//  PaywallView.swift
//  InAppKit
//
//  Main paywall view with modern design
//

import SwiftUI
import StoreKit
import OSLog

public struct PaywallView: View {
    @State private var inAppKit = InAppKit.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedProduct: Product?
    @State private var isRestoring = false
    @State private var showRestoreAlert = false
    @State private var restoreMessage: String?
    @State private var animationOffset: CGFloat = 50
    @State private var animationOpacity: Double = 0
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Modern gradient background
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.1),
                    Color.purple.opacity(0.05),
                    Color(NSColor.windowBackgroundColor)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    headerSection
                        .offset(y: animationOffset)
                        .opacity(animationOpacity)
                    
                    if inAppKit.availableProducts.isEmpty {
                        loadingSection
                    } else {
                        productsSection
                            .offset(y: animationOffset)
                            .opacity(animationOpacity)
                    }
                    
                    featuresSection
                        .offset(y: animationOffset)
                        .opacity(animationOpacity)
                    
                    footerSection
                        .offset(y: animationOffset)
                        .opacity(animationOpacity)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 32)
            }
        }
        .frame(width: 520, height: 700)
        .background(Color(NSColor.windowBackgroundColor))
        .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                animationOffset = 0
                animationOpacity = 1
            }
        }
        .alert("Restore Status", isPresented: $showRestoreAlert) {
            Button("OK") { }
        } message: {
            if let message = restoreMessage {
                Text(message)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Premium icon with gradient
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: "crown.fill")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(spacing: 8) {
                Text("Upgrade to Pro")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text("Unlock advanced features and premium support")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
        }
    }
    
    private var loadingSection: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
            
            Text("Loading products...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxHeight: 100)
    }
    
    private var footerSection: some View {
        VStack(spacing: 16) {
            // Restore button
            Button(action: {
                Task {
                    isRestoring = true
                    await inAppKit.restorePurchases()
                    
                    if inAppKit.hasAnyPurchase {
                        restoreMessage = "Purchases restored successfully!"
                        showRestoreAlert = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            dismiss()
                        }
                    } else {
                        restoreMessage = "No previous purchases found."
                        showRestoreAlert = true
                    }
                    
                    isRestoring = false
                }
            }) {
                HStack(spacing: 6) {
                    if isRestoring {
                        ProgressView()
                            .scaleEffect(0.8)
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    }
                    Text(isRestoring ? "Restoring..." : "Restore Purchases")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.blue)
                }
                .frame(height: 44)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(isRestoring)
            
            // Use the configurable terms and privacy footer
            TermsPrivacyFooter()
        }
    }
    
    private var productsSection: some View {
        VStack(spacing: 20) {
            ForEach(inAppKit.availableProducts, id: \.self) { product in
                PurchaseOptionCard(
                    product: product,
                    isSelected: selectedProduct?.id == product.id,
                    onSelect: { selectedProduct = product }
                )
            }
            
            if let selectedProduct = selectedProduct {
                Button(action: {
                    Task {
                        do {
                            try await inAppKit.purchase(selectedProduct)
                            dismiss()
                        } catch {
                            // Handle error
                        }
                    }
                }) {
                    HStack(spacing: 12) {
                        if inAppKit.isPurchasing {
                            ProgressView()
                                .scaleEffect(0.8)
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                        
                        Text(inAppKit.isPurchasing ? "Processing..." : "Purchase \(selectedProduct.displayPrice)")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        LinearGradient(
                            colors: [Color.blue, Color.blue.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(inAppKit.isPurchasing)
                .scaleEffect(inAppKit.isPurchasing ? 0.98 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: inAppKit.isPurchasing)
            }
        }
    }
    
    private var featuresSection: some View {
        VStack(spacing: 16) {
            Text("What's Included")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                FeatureRow(
                    icon: "star.fill",
                    title: "Premium Features",
                    subtitle: "Access to all advanced functionality"
                )
                FeatureRow(
                    icon: "heart.fill",
                    title: "Priority Support",
                    subtitle: "Get help when you need it most"
                )
                FeatureRow(
                    icon: "arrow.clockwise",
                    title: "Regular Updates",
                    subtitle: "New features and improvements"
                )
                FeatureRow(
                    icon: "checkmark.shield.fill",
                    title: "Lifetime Access",
                    subtitle: "One-time purchase, yours forever"
                )
            }
        }
        .padding(.vertical, 12)
    }
}

#Preview {
    PaywallView()
}
