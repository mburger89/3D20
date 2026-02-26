//
//  Rotation.swift
//  3D20
//
//  Created by Anson Burger on 7/6/25.
//

import RealityKit

internal class SpinSystem: System {
	static let query = EntityQuery(where: .has(SpinComponent.self))
	required init(scene: RealityKit.Scene) {}
	
	func update(context: SceneUpdateContext) {
		let entities = context.entities(matching: Self.query, updatingSystemWhen: .rendering)
		for entity in entities {
			guard let spinComponent = entity.components[SpinComponent.self]
			else { continue }
			
			let angleSpeed = spinComponent.rotationsPerSecond * .pi * 2
			entity.orientation *= simd_quatf(
				angle: Float(context.deltaTime) * angleSpeed, axis: spinComponent.axis
			)
		}
	}
}

/// A component that spins an entity indefinitely.
public struct SpinComponent: Component, Codable {
	/// The axis to spin around in local space.
	var axis: SIMD3<Float>
	/// The number of full rotations to perform per second.
	var rotationsPerSecond: Float = 0.1
	
	public init(from decoder: any Decoder) throws {
		Self.registerSystem()
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.axis = try container.decode(SIMD3<Float>.self, forKey: .axis)
		self.rotationsPerSecond = try container.decode(Float.self, forKey: .rotationsPerSecond)
	}
	
	init(axis: SIMD3<Float> = .init(0, 1, 0),rotationsPerSecond: Float = 0.1 ) {
		self.axis = axis
		self.rotationsPerSecond = rotationsPerSecond
		Self.registerSystem()
	}
	
	nonisolated
	private static func registerSystem() {
		Task {
			await SpinSystem.registerSystem()
		}
	}
}
