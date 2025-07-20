//
//  diceDataModel.swift
//  3D20
//
//  Created by Anson Burger on 6/30/25.
//
import RealityKit
import SwiftUI
import Foundation
import DiceEnv

@Observable
class DiceData: ObservableObject {
    var dice_name: String = "D20"
    var dice_bool: Bool = false
    var tray_name: String = "DiceTray"
    var dice_position: SIMD3<Float> = [0, 0.2, 0.04]
    var dice_type: String = "D20"
    
    func rollDice(content: inout RealityViewCameraContent) {
        if let DieEntity = content.entities.first(where: { $0.name == "dice_anchor" }) {
            if let die = DieEntity.children.first(where: { $0.name == "die" }) as? ModelEntity {
                die.position = self.dice_position
                die.transform.rotation = simd_quatf(angle: Float.random(in: 1.0 ..< 180.0), axis: SIMD3(1.0, 0.0, 0.0))
                // Clear any previous velocities using the correct RealityKit API
				if var motion = die.components[PhysicsMotionComponent.self] {
                    motion.linearVelocity = SIMD3<Float>.zero
                    motion.angularVelocity = SIMD3<Float>.zero
                    die.components.set(motion)
                }
                // Apply a random impulse to "throw" the die
                let impulse = SIMD3<Float>(
                    0, // Slight left/right randomness
                    0, // Upwards throw
					Float.random(in: -0.0001...0.0001) // Forward throw
                )
                die.applyLinearImpulse(impulse, relativeTo: nil)
                // Optionally: Add a random angular impulse for spinning
				let angularImpulse = SIMD3<Float>(0.0,Float.random(in: -0.001...0.001),0.0)
                die.applyAngularImpulse(angularImpulse, relativeTo: nil)
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
    
    @MainActor
    func addDice(content: inout RealityViewCameraContent) {
        if let die_ent = content.entities.first(where: { $0.name == "dice_anchor" }) {
            Task {
                if let dice_entity = try? await ModelEntity(named: String(self.dice_type)) {
                    let shapeRes: ShapeResource = try! await ShapeResource.generateConvex(from: dice_entity.model?.mesh ?? .generateBox(size: 0.10))
                    dice_entity.name = "die"
                    dice_entity.position = self.dice_position
                    dice_entity.setScale(SIMD3(0.03, 0.03, 0.03), relativeTo: nil)
                    dice_entity.components.set(PhysicsBodyComponent(shapes: [shapeRes], mass: 0.6,mode: .dynamic,))
                    dice_entity.components.set(CollisionComponent(shapes: [shapeRes], mode: .colliding))
                    dice_entity.physicsBody?.massProperties.inertia = SIMD3<Float>(0.5, 0.5, 0.5)
                    dice_entity.physicsBody?.isContinuousCollisionDetectionEnabled = true
                    dice_entity.transform.rotation = simd_quatf(
                        angle: Float.random(in: 1.0..<180.0),
                        axis: SIMD3(1.0, 0.0, 0.0)
                    )
                    die_ent.addChild(dice_entity)
                }
            }
        }
    }
    
    @MainActor
    func changeSkin(content: inout RealityViewCameraContent) {
        if let die_ent = content.entities.first(where: {$0.name == "dice_anchor"}) {
            Task {
                let material: ShaderGraphMaterial = try await ShaderGraphMaterial(named: "/Root/CellShader", from: "Scene.usda", in: DiceEnv.diceEnvBundle)
                if let die = die_ent.children.first(where: {$0.name == "die"}) as? ModelEntity {
                    die.model?.materials[0] = material
                }
            }
        }
    }
//    MARK: end of class
}
