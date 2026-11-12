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
}
