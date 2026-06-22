//
//  StoreFeaturedCard.swift
//  3D20
//

import SwiftUI

struct StoreFeaturedCard: View {
    let skin: SD
    let isDice: Bool
    let shopVM: ShopViewModel

    private var imageName: String { isDice ? skin.name : "tray_\(skin.name)" }

    var body: some View {
        VStack(spacing: 0) {
            // Space reserved so the die visually overflows above the card
            Color.clear.frame(height: 36)

            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)

                HStack {
                    Spacer()

                    VStack(alignment: .trailing, spacing: 8) {
                        Text(skin.displayName)
                            .font(.title3)
                            .foregroundStyle(.primary)

                        Text("Now Live!")
                            .font(.title2)
                            .bold()
                            .foregroundStyle(.primary)

                        SkinPurchaseButton(skin: skin, isDice: isDice, shopVM: shopVM)
                    }
                    .padding(.trailing, 20)
                    .padding(.vertical, 20)
                }
            }
            .frame(height: 155)
        }
        .overlay(alignment: .topLeading) {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 155)
                .rotationEffect(Angle(degrees: 345))
                .scaleEffect(1.1)
                .padding(.leading, 8)
                .padding(.top, 8)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        StoreFeaturedCard(
            skin: SD(name: "SteelDarkAged", displayName: "Aged Steel Dice Set"),
            isDice: true,
            shopVM: ShopViewModel()
        )
        .padding(.horizontal, 16)
        StoreFeaturedCard(
            skin: SD(name: "Sapphire", displayName: "Sapphire Dice Set"),
            isDice: true,
            shopVM: ShopViewModel()
        )
        .padding(.horizontal, 16)
    }
    .padding(.vertical)
    .background(.black)
    .preferredColorScheme(.dark)
}
