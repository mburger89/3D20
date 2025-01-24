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
}


struct ContentView : View {
    @Bindable private var diceData: DiceData = DiceData()
    var body: some View {
        ZStack {
            RealityView { content in
                async let tray = ModelEntity(named: diceData.tray_name)
                if let tray = try? await tray {
                    tray.setScale(SIMD3(0.0050, 0.0050, 0.0050), relativeTo: nil)
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
                }
                async let dice = ModelEntity(named: diceData.dice_name)
                if let dice = try? await dice {
                    dice.setScale(SIMD3(0.010, 0.010, 0.010), relativeTo: nil)
                    dice.position = [0, 0.2, 0]
                    dice.components.set(PhysicsBodyComponent())
                    try? await dice.components.set(CollisionComponent(shapes: [ShapeResource.generateConvex(from: dice.model?.mesh ?? .generateBox(size: 1.0))]))
                    dice.collision?.mode = .colliding
                    dice.collision?.filter = .default
                    dice.physicsBody?.mode = .dynamic
                    dice.physicsBody?.isContinuousCollisionDetectionEnabled = true
                }
                    // Create horizontal plane anchor for the content
                let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.01, 0.01)))
                try? await anchor.addChild(tray)
                try? await anchor.addChild(dice)
                    // Add the horizontal plane anchor to the scene
                content.add(anchor)

                content.camera = .spatialTracking
                
            } update: { content in
            }
//            this didn't work will need to find another way to change skin.
            VStack {
                Spacer()
                Button("Start") {
                    diceData.dice_name = "normalMapTest_d20"
                    diceData.dice_bool.toggle()
                }.padding(30)
            }
            
            }.edgesIgnoringSafeArea(.all)
    }

}

//#Preview {
//    ContentView()
//}
