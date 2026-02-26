//
//  DiceDataModel.swift
//  3D20
//
//  Created by Anson Burger on 9/9/25.
//
import Foundation
import RealityKit
import SwiftUI
import DiceEnv

@Observable
class DiceData: ObservableObject {
	var dice_bool: Bool = false
	var tray_name: String = "diceTray"
	var dice_type: String = "D20"
	var skin: String = "SteelDarkAged"
	var traySkin: String = "woodAcajou"
	var arExp: Bool = false
	var changeDieSkin: Bool = false
	var changeTraySkin: Bool = false
	var showDiceOptions: Bool = false
	var showSkinOptions: Bool = false
	var hasRolled: Bool = false
	var changeDie: Bool = false
	var dice_position: SIMD3<Float> = [0, 0.24, 0.0]
	var diceScale: SIMD3<Float> = SIMD3(0.15, 0.15, 0.15)
	var skinData: SDData = SDData()
	
	init() {
		skinData = parsedSDData()
	}
	
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
					Float.random(in: -0.001...0.001) // Forward throw
				)
				die.applyLinearImpulse(impulse, relativeTo: nil)
				// Optionally: Add a random angular impulse for spinning
				let angularImpulse = SIMD3<Float>(0.0,Float.random(in: -0.0001...0.0001),0.0)
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
				let material: ShaderGraphMaterial = try await ShaderGraphMaterial(named: "/Root/\(self.skin)/\(self.skin)_\(self.dice_type)", from: "Scene.usda", in: DiceEnv.diceEnvBundle)
				if let dice_entity = try? await Entity(named: "\(self.dice_type)", in: DiceEnv.diceEnvBundle).children.first {
					dice_entity.setScale(self.diceScale, relativeTo: nil)
					let shapeRes: ShapeResource = try! await ShapeResource.generateConvex(from: (dice_entity as! ModelEntity).model?.mesh ?? .generateBox(size: 0.10))
					dice_entity.name = "die"
					dice_entity.position = self.dice_position
					dice_entity.components.set(PhysicsBodyComponent(shapes: [shapeRes], mass: 0.6,mode: .dynamic,))
					dice_entity.components.set(CollisionComponent(shapes: [shapeRes], mode: .colliding))
					dice_entity.components.set(GroundingShadowComponent(castsShadow: true, receivesShadow: true))
					(dice_entity as! ModelEntity).physicsBody?.massProperties.inertia = SIMD3<Float>(0.5, 0.5, 0.5)
					(dice_entity as! ModelEntity).physicsBody?.isContinuousCollisionDetectionEnabled = true
					dice_entity.transform.rotation = simd_quatf(
						angle: Float.random(in: 1.0..<180.0),
						axis: SIMD3(1.0, 0.0, 0.0)
					)
					(dice_entity as! ModelEntity).model?.materials[0] = material
					die_ent.addChild(dice_entity)
				}
			}
		}
	}
	
	@MainActor
	func changeSkin(content: inout RealityViewCameraContent) {
		if let die_ent = content.entities.first(where: {$0.name == "dice_anchor"}) {
			Task {
				let material: ShaderGraphMaterial = try await ShaderGraphMaterial(named: "/Root/\(self.skin)/\(self.skin)_\(self.dice_type)", from: "Scene.usda", in: DiceEnv.diceEnvBundle)
				if let die = die_ent.children.first(where: {$0.name == "die"}) as? ModelEntity {
					die.model?.materials[0] = material
				}
			}
			self.changeDieSkin = false
		}
	}
	
	@MainActor
	func changeTraySkin(content: inout RealityViewCameraContent) {
		if let die_ent = content.entities.first(where: {$0.name == "dice_anchor"}) {
			if let tray_ent = die_ent.children.first(where: {$0.name == "Root"}) {
				Task {
					let material: ShaderGraphMaterial = try await ShaderGraphMaterial(named: "/Root/TraySkins/\(self.traySkin)_tray", from: "Scene.usda", in: DiceEnv.diceEnvBundle)
					if let tray = tray_ent.children[0].children.first(where: {$0.name == "tray"}) as? ModelEntity {
						tray.model?.materials[0] = material
					}
				}
				self.changeTraySkin = false
			}
		}
	}
	
	@MainActor
	func addTrayCover(content: inout RealityViewCameraContent) {
		if let tray_ent = content.entities.first(where: { $0.name == "dice_anchor" }) {
			Task {
				let material: ShaderGraphMaterial = try await ShaderGraphMaterial(named: "/Root/TraySkins/\(self.traySkin)_tray", from: "Scene.usda", in: DiceEnv.diceEnvBundle)
				let trayCover = try await Entity(named: "TrayAndCover", in: DiceEnv.diceEnvBundle)
				trayCover.setScale(SIMD3(0.4, 0.4, 0.4), relativeTo: nil)
				if let tray = trayCover.children[0].children.first(where: {$0.name == "Bottom"}) as? ModelEntity {
					let shapeRes: ShapeResource = try await ShapeResource.generateStaticMesh(from: tray.model?.mesh ?? .generateBox(size: 1.0))
					tray.position = [0, 0, 0]
					tray.name = "tray"
					tray.components.set(PhysicsBodyComponent(shapes:[shapeRes], mass: 1.0, mode: .static))
					tray.components.set(CollisionComponent(shapes: [shapeRes], mode: .colliding))
					tray.generateCollisionShapes(recursive: true, static: true)
					tray.physicsBody?.isContinuousCollisionDetectionEnabled = true
					tray.model?.materials[0] = material
				}
				if let cover = trayCover.children[0].children.first(where: {$0.name == "Cover"}) as? ModelEntity {
					let shapeRes: ShapeResource = try await ShapeResource.generateStaticMesh(from: cover.model?.mesh ?? .generateBox(size: 1.0))
					cover.name = "cover"
					cover.position = [0, 0.001, 0]
					cover.components.set(PhysicsBodyComponent(shapes:[shapeRes], mass: 1.0, mode: .static))
					cover.components.set(CollisionComponent(shapes: [shapeRes],isStatic: true))
					cover.collision?.mode = .colliding
					cover.physicsBody?.isContinuousCollisionDetectionEnabled = true
					cover.model?.materials[0] = SimpleMaterial(color: .clear, roughness: 0.0, isMetallic: false)
				}
				trayCover.position = [0,-0.5,0]
				tray_ent.addChild(trayCover)
			}
		}
	}
	//    MARK: end of class
	
	func parsedSDData() -> SDData {
		guard let url = Bundle.main.url(forResource: "SkinData", withExtension: "json") else {
			fatalError("Missing file: SkinData.json")
		}
		do {
			let data = try Data(contentsOf: url)
			let decoder = JSONDecoder()
			let decoded = try decoder.decode(SDData.self, from: data)
			// Return either dice or trays; here we'll return dice as a sensible default.
			return decoded
		} catch {
			print("Error decoding config: \(error)")
			return SDData()
		}
	}
}

