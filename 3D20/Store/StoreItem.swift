//
//  StoreItem.swift
//  3D20
//

import Foundation

struct StoreItem: Identifiable {
    let id = UUID()
    let imageName: String
    let displayName: String
    let price: String
    let category: StoreCategory
    var isFeatured: Bool = false
    var featuredSubtitle: String? = nil
}

extension StoreItem {
    static let all: [StoreItem] = [
        StoreItem(
            imageName: "SteelDarkAged",
            displayName: "Aged Steel",
            price: "$0.99",
            category: .metals,
            isFeatured: true,
            featuredSubtitle: "Now Live!"
        ),
        StoreItem(
            imageName: "GoldenDroid",
            displayName: "Golden Droid",
            price: "$0.99",
            category: .metals,
            isFeatured: true,
            featuredSubtitle: "Fan Favourite"
        ),
        StoreItem(
            imageName: "Sapphire",
            displayName: "Sapphire",
            price: "$0.99",
            category: .fantasy,
            isFeatured: true,
            featuredSubtitle: "New Arrival"
        ),
        StoreItem(imageName: "SteelDarkAged", displayName: "Aged Steel", price: "$0.99", category: .metals),
        StoreItem(imageName: "GoldenDroid", displayName: "Golden Droid", price: "$0.99", category: .metals),
        StoreItem(imageName: "DarkMarble", displayName: "Dark Marble", price: "$0.99", category: .fantasy),
        StoreItem(imageName: "Sapphire", displayName: "Sapphire", price: "$0.99", category: .fantasy),
        StoreItem(imageName: "BlueEdge", displayName: "Blue Edge", price: "$0.99", category: .sciFi),
        StoreItem(imageName: "PaintedWorn", displayName: "Painted Worn", price: "$0.99", category: .favorites),
    ]

    static var featured: [StoreItem] { all.filter(\.isFeatured) }
    static var grid: [StoreItem] { all.filter { !$0.isFeatured } }
}
