//
//  ContentView.swift
//  3D20
//
//  Created by Anson Burger on 12/3/24.
//

import ARKit
import RealityKit
import SwiftUI

struct ContentView: View {
    @State var diceData: DiceData = DiceData()
    @State private var hasRolled: Bool = false
    @State private var changeDie: Bool = false
    @State private var showSkinOptions: Bool = false
    @State private var showDiceOptions: Bool = false
    var body: some View {
        NavigationStack {
            ZStack {
                RealityView { content in
                    // Create horizontal plane anchor for the content
                    let anchor = AnchorEntity(
                        .plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.001, 0.001))
                    )
                    anchor.name = "dice_anchor"
                    Task {
                        if let tray = try? await ModelEntity(named: diceData.tray_name) {
                            tray.name = "tray"
                            tray.setScale(SIMD3(0.010, 0.010, 0.010), relativeTo: nil)
                            tray.position = [0, 0, 0]
                            tray.components.set(PhysicsBodyComponent())
                            try? await tray.components.set(
                                CollisionComponent(
                                    shapes: [
                                        ShapeResource.generateConvex(from: tray.model?.mesh ?? .generateBox(size: 1.0))
                                    ],
                                    isStatic: true
                                )
                            )
                            tray.collision?.mode = .colliding
                            tray.collision?.filter = .default
                            tray.physicsBody?.mode = .static
                            tray.physicsBody?.isContinuousCollisionDetectionEnabled = true
                            anchor.addChild(tray)
                        }
                    }
                    Task {
                        if let dice = try? await ModelEntity(named: diceData.dice_name) {
                            dice.name = "die"
                            dice.setScale(SIMD3(0.03, 0.03, 0.03), relativeTo: nil)
                            dice.position = diceData.dice_position
                            dice.components.set(PhysicsBodyComponent())
                            try? await dice.components.set(
                                CollisionComponent(shapes: [
                                    ShapeResource.generateConvex(from: dice.model?.mesh ?? .generateBox(size: 1.0))
                                ])
                            )
                            dice.collision?.mode = .colliding
                            dice.collision?.filter = .default
                            dice.physicsBody?.mode = .dynamic
                            dice.physicsBody?.isContinuousCollisionDetectionEnabled = true
                            dice.transform.rotation = simd_quatf(
                                angle: Float.random(in: 1.0..<180.0),
                                axis: SIMD3(1.0, 0.0, 0.0)
                            )
                            anchor.addChild(dice)
                            changeDie.toggle()
                        }
                    }

                    content.add(anchor)
                    content.camera = .spatialTracking

                } update: { content in
                    if hasRolled {
                        diceData.rollDice(content: &content)
                    }
                    if changeDie {
                        diceData.removeDice(content: &content)
                        if let die_ent = content.entities.first(where: { $0.name == "dice_anchor" }) {
                            if content.entities.first(where: { $0.name == "die" }) == nil {
                                Task {
                                    if let dice_entity = try? await ModelEntity(named: String(diceData.dice_type)) {
                                        dice_entity.name = "die"
                                        dice_entity.position = diceData.dice_position
                                        dice_entity.setScale(SIMD3(0.03, 0.03, 0.03), relativeTo: nil)
                                        dice_entity.components.set(PhysicsBodyComponent())
                                        dice_entity.collision?.mode = .colliding
                                        dice_entity.physicsBody?.mode = .dynamic
                                        dice_entity.physicsBody?.isContinuousCollisionDetectionEnabled = true
                                        try? await dice_entity.components.set(
                                            CollisionComponent(shapes: [
                                                ShapeResource.generateConvex(
                                                    from: dice_entity.model?.mesh ?? .generateBox(size: 1.0)
                                                )
                                            ])
                                        )
                                        dice_entity.transform.rotation = simd_quatf(
                                            angle: Float.random(in: 1.0..<180.0),
                                            axis: SIMD3(1.0, 0.0, 0.0)
                                        )
                                        die_ent.addChild(dice_entity)
                                    }
                                }
                            }
                        }
                    }
                }.onChange(of: hasRolled) {
                    if hasRolled { hasRolled = false }
                }.onChange(of: changeDie) {
                    if changeDie { changeDie = false }
                }
                .sheet(isPresented: $showDiceOptions, onDismiss: { changeDie.toggle() }) {
                    diceOptions(diceData: $diceData)
                }
                .sheet(isPresented: $showSkinOptions, onDismiss: {}) {
                    Text("Skins Coming Soon...")
                }
                VStack {
                    Spacer()
                    HStack {
                        Button("Change\n Skin") {
                            showSkinOptions.toggle()
                        }.buttonStyle(.bordered).padding(30)
                        Spacer()
                        Button("Change\n Dice") {
                            showDiceOptions.toggle()
                        }.buttonStyle(.bordered).padding(30)
                    }
                    HStack {
                        Button(action: {}) {
                            Image(systemName: "storefront").font(.largeTitle)
                        }
                        Button("\(Image("WoodDie"))") {
                            print("rolling")
                            hasRolled.toggle()
                            diceData.dice_position = [0, 0.23, 0]
                        }.frame(height: 80).scaledToFit()
                            .padding(.horizontal, 30)
//                        Button(action: { print("hello") }) {
//                            Image("skins")
//                        }
                        NavigationLink(destination: DetailView()) {
                            Image(systemName: "gear").font(.largeTitle)
                        }
                    }.padding(.bottom, 50)
                }
            }.edgesIgnoringSafeArea(.all)
        }

    }

}

#Preview {
    ContentView(diceData: DiceData())
}
