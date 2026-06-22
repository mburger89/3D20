//
//  SkinPurchaseButton.swift
//  3D20
//

import SwiftUI

struct SkinPurchaseButton: View {
    let skin: SD
    let isDice: Bool
    let shopVM: ShopViewModel

    var body: some View {
        if shopVM.isPurchased(skinName: skin.name, isDice: isDice) {
            Label("Owned", systemImage: "checkmark.circle.fill")
                .font(.caption.bold())
                .foregroundStyle(.green)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .glassEffect()
        } else if let product = shopVM.product(skinName: skin.name, isDice: isDice) {
            Button {
                Task { await shopVM.purchase(product) }
            } label: {
                Text(product.displayPrice)
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .glassEffect()
            }
            .buttonStyle(.plain)
        } else {
            Text("—")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .glassEffect()
        }
    }
}

#Preview {
    SkinPurchaseButton(
        skin: SD(name: "SteelDarkAged", displayName: "Aged Steel"),
        isDice: true,
        shopVM: ShopViewModel()
    )
    .padding()
}
