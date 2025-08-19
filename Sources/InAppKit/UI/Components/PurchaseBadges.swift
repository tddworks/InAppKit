//
//  PurchaseBadges.swift
//  InAppKit
//
//  Badge components for content requiring purchase
//

import SwiftUI

// MARK: - Purchase Required Badge

struct PurchaseRequiredBadge: View {
    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: "crown.fill")
                .font(.caption2)
            Text("PRO")
                .font(.caption2)
                .fontWeight(.bold)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(
            Capsule()
                .fill(LinearGradient(
                    colors: [.orange, .yellow],
                    startPoint: .leading,
                    endPoint: .trailing
                ))
        )
        .shadow(radius: 1)
    }
}
