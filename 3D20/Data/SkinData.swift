//
//  SkinData.swift
//  3D20
//
//  Created by Anson Burger on 7/29/25.
//

import Foundation

struct SD: Codable {
    let id: UUID
    let name: String
    var displayName: String = ""
    var description: String = ""
    
    init(name: String, displayName: String? = nil, description: String? = nil) {
        self.id = UUID()
        self.name = name
        self.displayName = displayName ?? name
        self.description = description ?? ""
    }
}

let SDArray: [SD] = [
    SD(
        name: "SteelDarkAged",
        displayName: "Aged Steel",
        description: "Aged Steel is a durable, dark-colored metal that is well used"
    ),
    SD(name: "PaintedWorn"),
    SD(name: "GoldenDroid"),
    SD(name: "DarkMarble"),
    SD(name: "Sapphire"),
    SD(name: "BlueEdge")
]

let traySkins: [SD] = [
    SD(name: "boneStylized"),
    SD(name: "bronzeArmor"),
    SD(name: "carbonFiber"),
    SD(name: "clayTerracotta"),
    SD(name: "creatureSkinGreen"),
    SD(name: "fabricWoolHerringbone"),
    SD(name: "fabricWoolJersey"),
    SD(name: "leatherCalfGrain"),
    SD(name: "leatherGrain"),
    SD(name: "leatherSofa"),
    SD(name: "leatherStylized"),
    SD(name: "leatherStylized-2"),
    SD(name: "leatheretteDamaged"),
    SD(name: "marbleFineWhite"),
    SD(name: "marblePolished"),
    SD(name: "marbleVeined"),
    SD(name: "marbleVerdiAlpi"),
    SD(name: "metalCyborg"),
    SD(name: "paintBrushed"),
    SD(name: "paintRoll"),
    SD(name: "plasticComposite"),
    SD(name: "plasticUsed"),
    SD(name: "plasticUsedSoft"),
    SD(name: "rubberDry"),
    SD(name: "rubberRaw"),
    SD(name: "steelDarkAged"),
    SD(name: "steelScratched"),
    SD(name: "stoneTravertine"),
    SD(name: "stylizedWoodPlain"),
    SD(name: "terazzoComposite"),
    SD(name: "woodAcajou"),
    SD(name: "woodPlain"),
]
