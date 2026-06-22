//
//  Store.swift
//  3D20
//

import SwiftUI
import StoreKit

struct Store: View {
    @Environment(DiceData.self) var diceData
    @State private var shopVM = ShopViewModel()
    @State private var selectedCategory: StoreCategory? = nil

    private var featuredItems: [(SD, Bool)] {
        let dice = ShopViewModel.featuredDiceNames.compactMap { name in
            diceData.skinData.dice.first { $0.name == name }.map { ($0, true) }
        }
        let trays = ShopViewModel.featuredTrayNames.compactMap { name in
            diceData.skinData.trays.first { $0.name == name }.map { ($0, false) }
        }
        return dice + trays
    }

    private var filteredDice: [SD] {
        switch selectedCategory {
        case .none:
            return diceData.skinData.dice
        case .favorites:
            return diceData.skinData.dice.filter { shopVM.isFavorite(skinName: $0.name, isDice: true) }
        case .some(let cat):
            return diceData.skinData.dice.filter { StoreCategory.category(for: $0.name) == cat }
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                featuredCarousel
                categoryButtons
                diceGrid
            }
            .padding(.vertical, 12)
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Dice Store")
        .background(.black)
        .task {
            await shopVM.loadProducts(skinData: diceData.skinData)
        }
    }

    private var featuredCarousel: some View {
        TabView {
            ForEach(featuredItems, id: \.0.name) { skin, isDice in
                StoreFeaturedCard(skin: skin, isDice: isDice, shopVM: shopVM)
                    .padding(.horizontal, 16).padding(.bottom, 50)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .frame(height: 225)
    }

    private var categoryButtons: some View {
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
    }

    private var diceGrid: some View {
        Group {
            if filteredDice.isEmpty {
                ContentUnavailableView(
                    "No Items",
                    systemImage: "dice",
                    description: Text("No dice in this category yet.")
                )
                .padding(.top, 40)
            } else {
                LazyVGrid(columns: [GridItem(), GridItem()], spacing: 16) {
                    ForEach(filteredDice, id: \.name) { skin in
                        StoreDiceCard(skin: skin, isDice: true, shopVM: shopVM)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private func toggleCategory(_ category: StoreCategory) {
        selectedCategory = selectedCategory == category ? nil : category
    }
}

#Preview {
    NavigationStack {
        Store()
            .environment(DiceData())
    }
    .preferredColorScheme(.dark)
}
