//
//  ShopViewModel.swift
//  3D20
//

import Foundation
import StoreKit

@Observable
class ShopViewModel {
    private(set) var products: [Product] = []
    private(set) var purchasedProductIDs: Set<String> = []
    private(set) var favoriteIDs: Set<String>
    private(set) var isLoading = false

    private static let diceSkinPrefix = "com.3d20.skin.dice."
    private static let traySkinPrefix = "com.3d20.skin.tray."

    // Curated featured skins shown at the top of the shop
    static let featuredDiceNames = ["Sapphire", "GoldenDroid", "BlueEdge"]
    static let featuredTrayNames = ["bronzeArmor", "carbonFiber"]

    init() {
        let saved = UserDefaults.standard.stringArray(forKey: "shop.favorites") ?? []
        favoriteIDs = Set(saved)
    }

    static func productID(skinName: String, isDice: Bool) -> String {
        isDice ? "\(diceSkinPrefix)\(skinName)" : "\(traySkinPrefix)\(skinName)"
    }

    func product(skinName: String, isDice: Bool) -> Product? {
        let id = Self.productID(skinName: skinName, isDice: isDice)
        return products.first { $0.id == id }
    }

    func isPurchased(skinName: String, isDice: Bool) -> Bool {
        purchasedProductIDs.contains(Self.productID(skinName: skinName, isDice: isDice))
    }

    func isFavorite(skinName: String, isDice: Bool) -> Bool {
        favoriteIDs.contains(Self.productID(skinName: skinName, isDice: isDice))
    }

    func toggleFavorite(skinName: String, isDice: Bool) {
        let id = Self.productID(skinName: skinName, isDice: isDice)
        if favoriteIDs.contains(id) {
            favoriteIDs.remove(id)
        } else {
            favoriteIDs.insert(id)
        }
        UserDefaults.standard.set(Array(favoriteIDs), forKey: "shop.favorites")
    }

    @MainActor
    func loadProducts(skinData: SDData) async {
        isLoading = true
        let allIDs: Set<String> = Set(
            skinData.dice.map { Self.productID(skinName: $0.name, isDice: true) } +
            skinData.trays.map { Self.productID(skinName: $0.name, isDice: false) }
        )
        do {
            products = try await Product.products(for: allIDs)
        } catch {}
        await refreshEntitlements()
        isLoading = false
    }

    @MainActor
    func refreshEntitlements() async {
        var purchased = Set<String>()
        for await result in Transaction.currentEntitlements {
            if case .verified(let tx) = result {
                purchased.insert(tx.productID)
            }
        }
        purchasedProductIDs = purchased
    }

    @MainActor
    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            if case .success(.verified(let tx)) = result {
                purchasedProductIDs.insert(tx.productID)
                await tx.finish()
            }
        } catch {}
    }
}
