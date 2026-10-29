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
	var diceScale: SIMD3<Float> = SIMD3(0.10, 0.10, 0.10)
	var skinData: SDData = SDData()

	// Settled roll result — nil while rolling or before first roll
	var settledFaceValue: Int? = nil
	var isDieReady: Bool = false
	private var activeDie: ModelEntity? = nil
	private var settlementTask: Task<Void, Never>? = nil
	// Convex shapes are expensive to compute; cache them by die type
	private var shapeCache: [String: ShapeResource] = [:]

	init() {
		skinData = parsedSDData()
		// Pre-warm: trigger entity loading now so the OS file cache is hot by the time the view loads
		Task {
			async let dieWarm = Entity(named: "D20", in: DiceEnv.diceEnvBundle)
			async let trayWarm = Entity(named: "TrayAndCover", in: DiceEnv.diceEnvBundle)
			_ = try? await dieWarm
			_ = try? await trayWarm
		}
	}

	func rollDice(content: inout RealityViewCameraContent) {
		if let DieEntity = content.entities.first(where: { $0.name == "dice_anchor" }) {
			if let die = DieEntity.children.first(where: { $0.name == "die" }) as? ModelEntity {
				die.position = self.dice_position
				// Randomize tumble across all three axes so every roll looks different
				let randomAxis = normalize(SIMD3<Float>(
					Float.random(in: -1...1),
					Float.random(in: -1...1),
					Float.random(in: -1...1)
				))
				die.transform.rotation = simd_quatf(
					angle: Float.random(in: 0..<Float.pi * 2),
					axis: randomAxis
				)
				// Clear any previous velocities
				if var motion = die.components[PhysicsMotionComponent.self] {
					motion.linearVelocity = SIMD3<Float>.zero
					motion.angularVelocity = SIMD3<Float>.zero
					die.components.set(motion)
				}
				// Small lateral throw so the die bounces off the tray walls before settling
				let impulse = SIMD3<Float>(
					Float.random(in: -0.001...0.001),
					0,
					Float.random(in: -0.001...0.001)
				)
				die.applyLinearImpulse(impulse, relativeTo: nil)
				// Strong tumble on all three axes for a convincing roll
				let angularImpulse = SIMD3<Float>(
					Float.random(in: -0.01...0.01),
					Float.random(in: -0.01...0.01),
					Float.random(in: -0.01...0.01)
				)
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
		activeDie = nil
		isDieReady = false
		settlementTask?.cancel()
	}

	@MainActor
	func addDice(content: inout RealityViewCameraContent) {
		if let die_ent = content.entities.first(where: { $0.name == "dice_anchor" }) {
			Task {
				do {
					// Load material and entity in parallel — both are independent I/O operations
					async let materialLoad = ShaderGraphMaterial(named: "/Root/\(self.skin)/\(self.skin)_\(self.dice_type)", from: "Scene.usda", in: DiceEnv.diceEnvBundle)
					async let entityLoad = Entity(named: "\(self.dice_type)", in: DiceEnv.diceEnvBundle)
					let material = try await materialLoad
					guard let dice_entity = try? await entityLoad.children.first as? ModelEntity else { return }

					// Re-use cached shape if available; generating convex hull is CPU-intensive
					let shapeRes: ShapeResource
					if let cached = self.shapeCache[self.dice_type] {
						shapeRes = cached
					} else {
						shapeRes = try await ShapeResource.generateConvex(from: dice_entity.model?.mesh ?? .generateBox(size: 0.10))
						self.shapeCache[self.dice_type] = shapeRes
					}
					dice_entity.name = "die"
					dice_entity.position = self.dice_position
					// Friction keeps the die from sliding forever; restitution gives it a natural bounce
					let physicsMaterial = PhysicsMaterialResource.generate(friction: 0.5, restitution: 0.35)
					dice_entity.components.set(PhysicsBodyComponent(shapes: [shapeRes], mass: 0.6, material: physicsMaterial, mode: .dynamic))
					dice_entity.components.set(CollisionComponent(shapes: [shapeRes], mode: .colliding))
					// Without this RealityKit never exposes velocities, and settlement detection can't tell rolling from resting
					dice_entity.components.set(PhysicsMotionComponent())
					dice_entity.components.set(GroundingShadowComponent(castsShadow: true, receivesShadow: true))
					dice_entity.physicsBody?.massProperties.inertia = SIMD3<Float>(0.5, 0.5, 0.5)
					dice_entity.physicsBody?.isContinuousCollisionDetectionEnabled = true
					// Random axis so the starting orientation is never the same
					dice_entity.transform.rotation = simd_quatf(
						angle: Float.random(in: 0..<Float.pi * 2),
						axis: normalize(SIMD3<Float>(
							Float.random(in: -1...1),
							Float.random(in: -1...1),
							Float.random(in: -1...1)
						))
					)
					dice_entity.model?.materials[0] = material
					die_ent.addChild(dice_entity)
					// Scale after re-parenting: the loaded USD root is in centimetres (scale 0.01), so a
					// world-space scale set before addChild leaves a local scale of 10 under the anchor.
					dice_entity.setScale(self.diceScale, relativeTo: nil)
					self.activeDie = dice_entity
					self.isDieReady = true
				} catch {
					print("Failed to add dice: \(error)")
				}
			}
		}
	}

	// MARK: - Settlement Detection

	@MainActor
	func startSettlementDetection() {
		settledFaceValue = nil
		settlementTask?.cancel()
		settlementTask = Task { @MainActor in
			// Give the die time to get moving before we start watching
			try? await Task.sleep(for: .seconds(0.8))
			var elapsed: Double = 0
			while !Task.isCancelled && elapsed < 10.0 {
				guard let die = activeDie else {
					// Die entity not yet ready — keep waiting rather than giving up
					try? await Task.sleep(for: .milliseconds(200))
					elapsed += 0.2
					continue
				}
				// A sleeping physics body has no PhysicsMotionComponent — that means it IS at rest
				guard let motion = die.components[PhysicsMotionComponent.self] else {
					withAnimation(.spring(duration: 0.4)) {
						settledFaceValue = detectFaceUp(die: die)
					}
					break
				}
				let linearStopped  = simd_length(motion.linearVelocity)  < 0.005
				let angularStopped = simd_length(motion.angularVelocity) < 0.01
				if linearStopped && angularStopped {
					withAnimation(.spring(duration: 0.4)) {
						settledFaceValue = detectFaceUp(die: die)
					}
					break
				}
				try? await Task.sleep(for: .milliseconds(200))
				elapsed += 0.2
			}
		}
	}

	private func detectFaceUp(die: ModelEntity) -> Int {
		let rotation = die.transform.rotation
		let normals = faceNormals(for: dice_type)
		// D4 shows its value on the bottom face, so find the normal pointing most downward
		let isD4 = dice_type == "D04"
		var bestValue = normals.first?.1 ?? 1
		var bestDot: Float = isD4 ? Float.infinity : -Float.infinity
		for (localNormal, value) in normals {
			let worldY = rotation.act(localNormal).y
			let beats = isD4 ? (worldY < bestDot) : (worldY > bestDot)
			if beats { bestDot = worldY; bestValue = value }
		}
		return bestValue
	}

	// Face normals in local model space paired with the face value.
	// Value-to-normal assignments are based on standard polyhedral geometry and
	// may need reordering per die type after testing against the actual models.
	private func faceNormals(for diceType: String) -> [(SIMD3<Float>, Int)] {
		switch diceType {
		case "D04": return d4Normals
		case "D06": return d6Normals
		case "D08": return d8Normals
		case "D10": return d10Normals
		case "D12": return d12Normals
		default:    return d20Normals
		}
	}

	private var d4Normals: [(SIMD3<Float>, Int)] {
		// Regular tetrahedron inscribed in a cube; face normals are outward from centroid
		[
			(normalize(SIMD3<Float>(-1, -1, -1)), 1),
			(normalize(SIMD3<Float>( 1,  1, -1)), 2),
			(normalize(SIMD3<Float>( 1, -1,  1)), 3),
			(normalize(SIMD3<Float>(-1,  1,  1)), 4),
		]
	}

	private var d6Normals: [(SIMD3<Float>, Int)] {
		// Cube faces along the six cardinal axes; opposite faces sum to 7
		[
			(SIMD3<Float>( 0,  1,  0), 1),
			(SIMD3<Float>( 0, -1,  0), 6),
			(SIMD3<Float>( 1,  0,  0), 2),
			(SIMD3<Float>(-1,  0,  0), 5),
			(SIMD3<Float>( 0,  0,  1), 3),
			(SIMD3<Float>( 0,  0, -1), 4),
		]
	}

	private var d8Normals: [(SIMD3<Float>, Int)] {
		// Regular octahedron — all eight (±1,±1,±1)/√3 normals
		let s: Float = 1 / sqrt(3)
		return [
			(SIMD3<Float>( s,  s,  s), 1), (SIMD3<Float>(-s,  s,  s), 2),
			(SIMD3<Float>( s, -s,  s), 3), (SIMD3<Float>(-s, -s,  s), 4),
			(SIMD3<Float>( s,  s, -s), 5), (SIMD3<Float>(-s,  s, -s), 6),
			(SIMD3<Float>( s, -s, -s), 7), (SIMD3<Float>(-s, -s, -s), 8),
		]
	}

	private var d10Normals: [(SIMD3<Float>, Int)] {
		// Pentagonal trapezohedron: 5 upper and 5 lower kite faces
		let yUp: Float  = 0.4472   // sin(arctan(0.5))
		let r: Float    = 0.8944   // cos(arctan(0.5))
		let step: Float = .pi * 2 / 5
		var result: [(SIMD3<Float>, Int)] = []
		for k in 0..<5 {
			let azUpper = step * Float(k) + .pi / 10
			let azLower = step * Float(k)
			result.append((normalize(SIMD3<Float>(r * cos(azUpper),  yUp, r * sin(azUpper))), k * 2 + 1))
			result.append((normalize(SIMD3<Float>(r * cos(azLower), -yUp, r * sin(azLower))), k * 2 + 2))
		}
		return result
	}

	private var d12Normals: [(SIMD3<Float>, Int)] {
		// Dodecahedron face normals == icosahedron vertex directions
		let phi: Float = (1 + sqrt(5)) / 2
		let verts: [SIMD3<Float>] = [
			[ 0,  1,  phi], [ 0, -1,  phi], [ 0,  1, -phi], [ 0, -1, -phi],
			[ 1,  phi,  0], [-1,  phi,  0], [ 1, -phi,  0], [-1, -phi,  0],
			[ phi,  0,  1], [-phi,  0,  1], [ phi,  0, -1], [-phi,  0, -1],
		]
		return verts.enumerated().map { (i, v) in (normalize(v), i + 1) }
	}

	private var d20Normals: [(SIMD3<Float>, Int)] {
		// Regular icosahedron: 20 face normals = normalized centroids of each triangle
		let phi: Float = (1 + sqrt(5)) / 2
		let v: [SIMD3<Float>] = [
			[ 0,  1,  phi], [ 0, -1,  phi], [ 0,  1, -phi], [ 0, -1, -phi],
			[ 1,  phi,  0], [-1,  phi,  0], [ 1, -phi,  0], [-1, -phi,  0],
			[ phi,  0,  1], [-phi,  0,  1], [ phi,  0, -1], [-phi,  0, -1],
		]
		let faces: [(Int, Int, Int)] = [
			(0,1,8),  (0,8,4),  (0,4,5),  (0,5,9),  (0,9,1),
			(1,6,8),  (8,6,10), (8,10,4), (4,10,2), (4,2,5),
			(5,2,11), (5,11,9), (9,11,7), (9,7,1),  (1,7,6),
			(3,2,10), (3,10,6), (3,6,7),  (3,7,11), (3,11,2),
		]
		// Face value lookup — confirmed faces marked ✓, others are best-effort and may need adjustment.
		// Opposite faces always sum to 21 (standard D20 rule).
		let faceValues: [Int] = [
			 1,  // i=0  ✓ confirmed
			 2,  // i=1  unverified
			 3,  // i=2  unverified
			12,  // i=3  ✓ confirmed
			 4,  // i=4  unverified
			 5,  // i=5  ✓ confirmed (opposite of i=10)
			 6,  // i=6  unverified
			 8,  // i=7  ✓ confirmed
			 7,  // i=8  unverified
			10,  // i=9  unverified
			16,  // i=10 ✓ confirmed
			15,  // i=11 unverified
			13,  // i=12 ✓ confirmed (opposite of i=7)
			14,  // i=13 unverified
			11,  // i=14 unverified
			17,  // i=15 unverified
			 9,  // i=16 ✓ confirmed (opposite of i=3)
			18,  // i=17 unverified
			19,  // i=18 unverified
			20,  // i=19 ✓ confirmed (opposite of i=0)
		]
		return faces.enumerated().map { (i, f) in
			(normalize(v[f.0] + v[f.1] + v[f.2]), faceValues[i])
		}
	}

	// MARK: -

	@MainActor
	func changeSkin(content: inout RealityViewCameraContent) {
		if let die_ent = content.entities.first(where: {$0.name == "dice_anchor"}) {
			Task {
				do {
					let material: ShaderGraphMaterial = try await ShaderGraphMaterial(named: "/Root/\(self.skin)/\(self.skin)_\(self.dice_type)", from: "Scene.usda", in: DiceEnv.diceEnvBundle)
					if let die = die_ent.children.first(where: {$0.name == "die"}) as? ModelEntity {
						die.model?.materials[0] = material
					}
				} catch {
					print("Failed to change skin: \(error)")
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
					do {
						let material: ShaderGraphMaterial = try await ShaderGraphMaterial(named: "/Root/TraySkins/\(self.traySkin)_tray", from: "Scene.usda", in: DiceEnv.diceEnvBundle)
						if let tray = tray_ent.children[0].children.first(where: {$0.name == "tray"}) as? ModelEntity {
							tray.model?.materials[0] = material
						}
					} catch {
						print("Failed to change tray skin: \(error)")
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
				do {
					// Load material and entity in parallel
					async let materialLoad = ShaderGraphMaterial(named: "/Root/TraySkins/\(self.traySkin)_tray", from: "Scene.usda", in: DiceEnv.diceEnvBundle)
					async let entityLoad = Entity(named: "TrayAndCover", in: DiceEnv.diceEnvBundle)
					let material = try await materialLoad
					let trayCover = try await entityLoad
					trayCover.setScale(SIMD3(0.4, 0.4, 0.4), relativeTo: nil)

					guard let tray = trayCover.children[0].children.first(where: {$0.name == "Bottom"}) as? ModelEntity,
					      let cover = trayCover.children[0].children.first(where: {$0.name == "Cover"}) as? ModelEntity else {
						return
					}

					// Extract meshes on the main actor before handing off to the async let child tasks
					let trayMesh = tray.model?.mesh ?? MeshResource.generateBox(size: 1.0)
					let coverMesh = cover.model?.mesh ?? MeshResource.generateBox(size: 1.0)
					// Generate both collision shapes in parallel
					async let bottomShapeLoad = ShapeResource.generateStaticMesh(from: trayMesh)
					async let coverShapeLoad = ShapeResource.generateStaticMesh(from: coverMesh)
					let bottomShape = try await bottomShapeLoad
					let coverShape = try await coverShapeLoad

					tray.position = [0, 0, 0]
					tray.name = "tray"
					tray.components.set(PhysicsBodyComponent(shapes:[bottomShape], mass: 1.0, mode: .static))
					tray.components.set(CollisionComponent(shapes: [bottomShape], mode: .colliding))
					tray.generateCollisionShapes(recursive: true, static: true)
					tray.physicsBody?.isContinuousCollisionDetectionEnabled = true
					tray.model?.materials[0] = material

					cover.name = "cover"
					cover.position = [0, 0.001, 0]
					cover.components.set(PhysicsBodyComponent(shapes:[coverShape], mass: 1.0, mode: .static))
					cover.components.set(CollisionComponent(shapes: [coverShape], isStatic: true))
					cover.collision?.mode = .colliding
					cover.physicsBody?.isContinuousCollisionDetectionEnabled = true
					cover.model?.materials[0] = SimpleMaterial(color: .clear, roughness: 0.0, isMetallic: false)

					trayCover.position = [0,-0.5,0]
					tray_ent.addChild(trayCover)
				} catch {
					print("Failed to add tray cover: \(error)")
				}
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
			return decoded
		} catch {
			print("Error decoding config: \(error)")
			return SDData()
		}
	}
}
