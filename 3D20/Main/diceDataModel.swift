//
//  diceDataModel.swift
//  3D20
//
//  Created by Anson Burger on 6/30/25.
//
import RealityKit
import SwiftUI
import Foundation

@Observable
class DiceData: ObservableObject {
    var dice_name: String = "D20"
    var dice_bool: Bool = false
    var tray_name: String = "dice_tray"
    var dice_position: SIMD3<Float> = [0, 0.2, 0]
    var dice_type: String = "D20"
    
    func rollDice(content: inout RealityViewCameraContent) {
        if let DieEntity = content.entities.first(where: { $0.name == "dice_anchor" }) {
            if let die = DieEntity.children.first(where: { $0.name == "die" }) {
                die.position = self.dice_position
                die.transform.rotation = simd_quatf(angle: Float.random(in: 1.0 ..< 180.0), axis: SIMD3(1.0, 0.0, 0.0))
            }
        }
    }
    
    func removeDice(content: inout RealityViewCameraContent) {
        if let die_ent = content.entities.first(where: { $0.name == "dice_anchor" }) {
            if let die = die_ent.children.first(where: { $0.name == "die" }) {
                die_ent.removeChild(die)
            }
        }
    }
}

