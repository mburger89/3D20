//
//  Store.swift
//  3D20
//

import SwiftUI

struct Store: View {
    @State private var selectedCategory: StoreCategory? = nil

    private var filteredItems: [StoreItem] {
        guard let cat = selectedCategory else { return StoreItem.grid }
        return StoreItem.grid.filter { $0.category == cat }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                TabView {
                    ForEach(StoreItem.featured) { item in
                        FeaturedBannerCard(item: item)
                            .padding(.horizontal, 16)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .frame(height: 220)

                LazyVGrid(columns: [GridItem(), GridItem()], spacing: 12) {
                    ForEach(StoreCategory.allCases) { category in
                        Button(category.rawValue, action: { toggleCategory(category) })
                            .font(.headline)
                            .bold()
                            .foregroundStyle(selectedCategory == category ? .primary : .secondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .glassEffect(in: .rect(cornerRadius: 16))
                    }
                }
                .padding(.horizontal, 16)

                if filteredItems.isEmpty {
                    ContentUnavailableView(
                        "No Items",
                        systemImage: "dice",
                        description: Text("No dice in this category yet.")
                    )
                    .padding(.top, 40)
                } else {
                    LazyVGrid(columns: [GridItem(), GridItem()], spacing: 16) {
                        ForEach(filteredItems) { item in
                            StoreDiceCard(item: item)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            .padding(.vertical, 12)
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Dice Store")
        .background(.black)
    }

    private func toggleCategory(_ category: StoreCategory) {
        selectedCategory = selectedCategory == category ? nil : category
    }
}

#Preview {
    NavigationStack {
        Store()
    }
    .preferredColorScheme(.dark)
}
