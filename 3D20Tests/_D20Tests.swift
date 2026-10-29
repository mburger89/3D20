//
//  _D20Tests.swift
//  3D20Tests
//
//  Created by Anson Burger on 12/3/24.
//

import Testing
import Foundation
@testable import _D20

// MARK: - SD Tests

@Suite("SD Model")
struct SDTests {

    @Test func initWithNameOnlyDefaultsDisplayName() {
        let skin = SD(name: "BlueEdge")
        #expect(skin.name == "BlueEdge")
        #expect(skin.displayName == "BlueEdge")
        #expect(skin.description == "")
        #expect(skin.id != nil)
    }

    @Test func initWithAllParamsSetsAllFields() {
        let skin = SD(name: "BlueEdge", displayName: "Blue Edge", description: "A sci-fi skin")
        #expect(skin.name == "BlueEdge")
        #expect(skin.displayName == "Blue Edge")
        #expect(skin.description == "A sci-fi skin")
    }

    @Test func codableRoundTrip() throws {
        let original = SD(name: "Sapphire", displayName: "Sapphire Gem", description: "Blue gem")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(SD.self, from: data)
        #expect(decoded.name == original.name)
        #expect(decoded.displayName == original.displayName)
        #expect(decoded.description == original.description)
    }

    @Test func twoInstancesWithSameNameHaveDifferentIDs() {
        let a = SD(name: "Steel")
        let b = SD(name: "Steel")
        #expect(a.id != b.id)
        #expect(a != b)
    }

    @Test func decodingWithMissingOptionalFieldsUsesDefaults() throws {
        // displayName falls back to name, description falls back to ""
        let json = #"{"name": "BlueEdge"}"#.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(SD.self, from: json)
        #expect(decoded.name == "BlueEdge")
        #expect(decoded.displayName == "BlueEdge")
        #expect(decoded.description == "")
    }
}

// MARK: - SDData Tests

@Suite("SDData Model")
struct SDDataTests {

    @Test func emptyInitProducesEmptyCollections() {
        let data = SDData()
        #expect(data.dice.isEmpty)
        #expect(data.trays.isEmpty)
        #expect(data.id != nil)
    }

    @Test func decodesFromJSON() throws {
        let json = """
        {
            "dice": [
                {"name": "SteelDarkAged", "displayName": "Aged Steel", "description": "Desc"}
            ],
            "trays": [
                {"name": "woodAcajou", "displayName": "Acajou Wood", "description": ""}
            ]
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(SDData.self, from: json)
        #expect(decoded.dice.count == 1)
        #expect(decoded.dice.first?.name == "SteelDarkAged")
        #expect(decoded.dice.first?.displayName == "Aged Steel")
        #expect(decoded.trays.count == 1)
        #expect(decoded.trays.first?.name == "woodAcajou")
    }

    @Test func decodesMultipleSkinsInEachCategory() throws {
        let json = """
        {
            "dice": [
                {"name": "A", "displayName": "Alpha", "description": ""},
                {"name": "B", "displayName": "Beta", "description": ""}
            ],
            "trays": [
                {"name": "T1", "displayName": "Tray One", "description": ""},
                {"name": "T2", "displayName": "Tray Two", "description": ""},
                {"name": "T3", "displayName": "Tray Three", "description": ""}
            ]
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(SDData.self, from: json)
        #expect(decoded.dice.count == 2)
        #expect(decoded.trays.count == 3)
    }

    @Test func codableRoundTrip() throws {
        let json = """
        {
            "dice": [{"name": "Sapphire", "displayName": "Sapphire", "description": ""}],
            "trays": []
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(SDData.self, from: json)
        let reEncoded = try JSONEncoder().encode(decoded)
        let roundTripped = try JSONDecoder().decode(SDData.self, from: reEncoded)
        #expect(roundTripped.dice.count == decoded.dice.count)
        #expect(roundTripped.dice.first?.name == decoded.dice.first?.name)
    }
}

// MARK: - ShopViewModel Tests

@Suite("ShopViewModel")
struct ShopViewModelTests {

    @Test func productIDForDiceSkin() {
        let id = ShopViewModel.productID(skinName: "Sapphire", isDice: true)
        #expect(id == "com.3d20.skin.dice.Sapphire")
    }

    @Test func productIDForTraySkin() {
        let id = ShopViewModel.productID(skinName: "woodAcajou", isDice: false)
        #expect(id == "com.3d20.skin.tray.woodAcajou")
    }

    @Test func productIDPrefixesAreDifferent() {
        let diceID = ShopViewModel.productID(skinName: "Steel", isDice: true)
        let trayID = ShopViewModel.productID(skinName: "Steel", isDice: false)
        #expect(diceID != trayID)
        #expect(diceID.hasPrefix("com.3d20.skin.dice."))
        #expect(trayID.hasPrefix("com.3d20.skin.tray."))
    }

    @Test func isPurchasedReturnsFalseByDefault() {
        let vm = ShopViewModel()
        #expect(!vm.isPurchased(skinName: "Sapphire", isDice: true))
        #expect(!vm.isPurchased(skinName: "woodAcajou", isDice: false))
    }

    @Test func productReturnsNilWhenNoProductsLoaded() {
        let vm = ShopViewModel()
        #expect(vm.product(skinName: "Sapphire", isDice: true) == nil)
    }

    @Test func toggleFavoriteAddsThenRemoves() {
        let vm = ShopViewModel()
        // Use a unique name so UserDefaults state from other tests doesn't interfere
        let name = "TestSkin_\(UUID().uuidString)"

        #expect(!vm.isFavorite(skinName: name, isDice: true))

        vm.toggleFavorite(skinName: name, isDice: true)
        #expect(vm.isFavorite(skinName: name, isDice: true))

        vm.toggleFavorite(skinName: name, isDice: true)
        #expect(!vm.isFavorite(skinName: name, isDice: true))
    }

    @Test func favoritingDiceSkinDoesNotAffectTraySkin() {
        let vm = ShopViewModel()
        let name = "SharedName_\(UUID().uuidString)"

        vm.toggleFavorite(skinName: name, isDice: true)
        #expect(vm.isFavorite(skinName: name, isDice: true))
        #expect(!vm.isFavorite(skinName: name, isDice: false))
    }

    @Test func featuredDiceNamesContainsExpectedSkins() {
        #expect(ShopViewModel.featuredDiceNames.contains("Sapphire"))
        #expect(ShopViewModel.featuredDiceNames.contains("GoldenDroid"))
        #expect(ShopViewModel.featuredDiceNames.contains("BlueEdge"))
    }

    @Test func featuredTrayNamesContainsExpectedSkins() {
        #expect(ShopViewModel.featuredTrayNames.contains("bronzeArmor"))
        #expect(ShopViewModel.featuredTrayNames.contains("carbonFiber"))
    }
}

// MARK: - StoreCategory Tests

@Suite("StoreCategory")
struct StoreCategoryTests {

    @Test func categoryLookupForKnownSkins() {
        #expect(StoreCategory.category(for: "SteelDarkAged") == .metals)
        #expect(StoreCategory.category(for: "GoldenDroid") == .metals)
        #expect(StoreCategory.category(for: "BlueEdge") == .sciFi)
        #expect(StoreCategory.category(for: "PaintedWorn") == .fantasy)
        #expect(StoreCategory.category(for: "DarkMarble") == .fantasy)
        #expect(StoreCategory.category(for: "Sapphire") == .fantasy)
    }

    @Test func categoryLookupForUnknownSkinReturnsNil() {
        #expect(StoreCategory.category(for: "UnknownSkin") == nil)
        #expect(StoreCategory.category(for: "") == nil)
    }

    @Test func idEqualsRawValue() {
        for category in StoreCategory.allCases {
            #expect(category.id == category.rawValue)
        }
    }

    @Test func allCasesHasFourEntries() {
        #expect(StoreCategory.allCases.count == 4)
    }

    @Test func allRawValuesPresent() {
        let rawValues = Set(StoreCategory.allCases.map(\.rawValue))
        #expect(rawValues.contains("Favorites"))
        #expect(rawValues.contains("Metals"))
        #expect(rawValues.contains("Sci-fi"))
        #expect(rawValues.contains("Fantasy"))
    }

    @Test func diceMappingDoesNotIncludeFavoritesCategory() {
        let mappedCategories = Set(StoreCategory.diceMapping.values)
        #expect(!mappedCategories.contains(.favorites))
    }

    @Test func diceMappingCoversAllSkinNamesInJSON() {
        // Every key in diceMapping should correspond to a skin in SkinData.json
        let knownDiceSkins: Set<String> = ["SteelDarkAged", "GoldenDroid", "PaintedWorn",
                                           "DarkMarble", "Sapphire", "BlueEdge"]
        for key in StoreCategory.diceMapping.keys {
            #expect(knownDiceSkins.contains(key), "Unexpected skin in diceMapping: \(key)")
        }
    }
}
