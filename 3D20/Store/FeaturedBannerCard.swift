//
//  FeaturedBannerCard.swift
//  3D20
//

import SwiftUI

struct FeaturedBannerCard: View {
    let item: StoreItem

    var body: some View {
        VStack(spacing: 0) {
            // Reserve space so the die overflows above the card
            Color.clear.frame(height: 36)

            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)

                HStack {
                    Spacer()

                    VStack(alignment: .trailing, spacing: 8) {
                        Text(item.displayName)
                            .font(.title3)
                            .foregroundStyle(.primary)

                        if let subtitle = item.featuredSubtitle {
                            Text(subtitle)
                                .font(.title2)
                                .bold()
                                .foregroundStyle(.primary)
                        }

                        Text("Only \(item.price)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 8)
                            .background(.regularMaterial)
                            .clipShape(.capsule)
                    }
                    .padding(.trailing, 20)
                    .padding(.vertical, 20)
                }
            }
            .frame(height: 155)
        }
        .overlay(alignment: .topLeading) {
            Image(item.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 160)
                .padding(.leading, 8)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        ForEach(StoreItem.featured) { item in
            FeaturedBannerCard(item: item)
                .padding(.horizontal, 16)
        }
    }
    .padding(.vertical)
    .background(.black)
    .preferredColorScheme(.dark)
}
