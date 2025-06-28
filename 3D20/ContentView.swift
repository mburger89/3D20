//
//  ContentView.swift
//  3D20
//
//  Created by Anson Burger on 12/3/24.
//

import SwiftUI
import RealityKit
import ARKit

@Observable
class DiceData {
    var dice_name: String = "D20_temp"
    var dice_bool: Bool = false
    var tray_name: String = "dice_tray"
    var dice_position: SIMD3<Float> = [0, 0.2, 0]
}


struct ContentView : View {
    @Bindable var diceData: DiceData = DiceData()
    @State private var isVisible: Bool = true
    var body: some View {
        ZStack {
            RealityView { content in
                // Create horizontal plane anchor for the content
                let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.001, 0.001)))
                anchor.name = "dice_anchor"
                if let tray = try? await ModelEntity(named: diceData.tray_name) {
                    tray.setScale(SIMD3(0.010, 0.010, 0.010), relativeTo: nil)
                    tray.position = [0, 0, 0]
                    tray.components.set(PhysicsBodyComponent())
                    try? await tray.components.set(CollisionComponent(
                        shapes: [ShapeResource.generateConvex(from: tray.model?.mesh ?? .generateBox(size: 1.0))],
                        isStatic: true)
                    )
                    tray.collision?.mode = .colliding
                    tray.collision?.filter = .default
                    tray.physicsBody?.mode = .static
                    tray.physicsBody?.isContinuousCollisionDetectionEnabled = true
                    anchor.addChild(tray)
                }
               if let dice = try? await ModelEntity(named: diceData.dice_name) {
                    dice.name = "die"
                    dice.setScale(SIMD3(0.03, 0.03, 0.03), relativeTo: nil)
                   dice.position = [0, 0.2, 0]
                    dice.components.set(PhysicsBodyComponent())
                    try? await dice.components.set(CollisionComponent(shapes: [ShapeResource.generateConvex(from: dice.model?.mesh ?? .generateBox(size: 1.0))]))
                    dice.collision?.mode = .colliding
                    dice.collision?.filter = .default
                    dice.physicsBody?.mode = .dynamic
                    dice.physicsBody?.isContinuousCollisionDetectionEnabled = true
                    dice.transform.rotation = simd_quatf(angle: Float.random(in: 1.0 ..< 360.0), axis: SIMD3(1.0, 0.0, 0.0))
                    anchor.addChild(dice)
                }
                
                content.add(anchor)

                content.camera = .spatialTracking
                
            } update: { content in
                if let DieEntity = content.entities.first(where: { $0.name == "dice_anchor" }) {
                    if let die = DieEntity.children.first(where: { $0.name == "die" }) {
                            die.position = diceData.dice_position
                            die.transform.rotation = simd_quatf(angle: Float.random(in: 1.0 ..< 360.0), axis: SIMD3(1.0, 0.0, 0.0))
                        }
                    }
            }
//            this didn't work will need to find another way to change skin.
            VStack {
                Spacer()
                Button("Roll") {
//                    diceData.dice_name = "normalMapTest_d20"
//                    diceData.dice_bool.toggle()
//                    print(isVisible)
                    diceData.dice_position = [0, 0.21, 0]
                }.padding(30).buttonStyle(.borderedProminent)
            }
            
            }.edgesIgnoringSafeArea(.all)
    }
}
