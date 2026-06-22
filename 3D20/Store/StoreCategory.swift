//
//  StoreCategory.swift
//  3D20
//

import Foundation

enum StoreCategory: String, CaseIterable, Identifiable {
    case favorites = "Favorites"
    case metals = "Metals"
    case sciFi = "Sci-fi"
    case fantasy = "Fantasy"

    var id: String { rawValue }

    static let diceMapping: [String: StoreCategory] = [
        "SteelDarkAged": .metals,
        "GoldenDroid": .metals,
        "PaintedWorn": .fantasy,
        "DarkMarble": .fantasy,
        "Sapphire": .fantasy,
        "BlueEdge": .sciFi,
    ]

    static func category(for skinName: String) -> StoreCategory? {
        diceMapping[skinName]
    }
}
