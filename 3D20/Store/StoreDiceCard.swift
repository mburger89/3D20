//
//  StoreDiceCard.swift
//  3D20
//

import SwiftUI

struct StoreDiceCard: View {
    let skin: SD
    let isDice: Bool
    let shopVM: ShopViewModel

    private var imageName: String { isDice ? skin.name : "tray_\(skin.name)" }

    var body: some View {
        VStack(spacing: 0) {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(20)

            Text(skin.displayName)
                .font(.subheadline)
                .bold()
                .foregroundStyle(.primary)
                .lineLimit(1)
                .padding(.bottom, 6)

            SkinPurchaseButton(skin: skin, isDice: isDice, shopVM: shopVM)
                .padding(.bottom, 14)
        }
        .background(.ultraThinMaterial)
        .clipShape(.rect(cornerRadius: 20))
    }
}

#Preview {
    LazyVGrid(columns: [GridItem(), GridItem()], spacing: 16) {
        StoreDiceCard(
            skin: SD(name: "SteelDarkAged", displayName: "Aged Steel"),
            isDice: true,
            shopVM: ShopViewModel()
        )
        StoreDiceCard(
            skin: SD(name: "Sapphire", displayName: "Sapphire"),
            isDice: true,
            shopVM: ShopViewModel()
        )
        StoreDiceCard(
            skin: SD(name: "GoldenDroid", displayName: "Golden Droid"),
            isDice: true,
            shopVM: ShopViewModel()
        )
        StoreDiceCard(
            skin: SD(name: "BlueEdge", displayName: "Blue Edge"),
            isDice: true,
            shopVM: ShopViewModel()
        )
    }
    .padding()
    .background(.black)
    .preferredColorScheme(.dark)
}
