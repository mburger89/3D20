//
//  StoreDiceCard.swift
//  3D20
//

import SwiftUI

struct StoreDiceCard: View {
    let item: StoreItem

    var body: some View {
        VStack(spacing: 0) {
            Image(item.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(20)

            Text(item.displayName)
                .font(.subheadline)
                .bold()
                .foregroundStyle(.primary)
                .padding(.bottom, 6)

            Text(item.price)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 28)
                .padding(.vertical, 6)
                .background(.regularMaterial)
                .clipShape(.capsule)
                .padding(.bottom, 14)
        }
        .background(.ultraThinMaterial)
        .clipShape(.rect(cornerRadius: 20))
    }
}

#Preview {
    LazyVGrid(columns: [GridItem(), GridItem()], spacing: 16) {
        ForEach(StoreItem.grid) { item in
            StoreDiceCard(item: item)
        }
    }
    .padding()
    .preferredColorScheme(.dark)
}
