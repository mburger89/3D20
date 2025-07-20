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
    @State private var changeDieSkin: Bool = false
    var body: some View {
        NavigationStack {
            ZStack {
                RealityView { content in
                    // Create horizontal plane anchor for the content
                    let anchor = AnchorEntity(
                        .plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.01, 0.01))
                    )
                    anchor.name = "dice_anchor"
                    Task {
                        if let tray = try? await ModelEntity(named: diceData.tray_name) {
                            let shapeRes: ShapeResource = try await ShapeResource.generateStaticMesh(from: tray.model?.mesh ?? .generateBox(size: 1.0))
                            tray.name = "tray"
                            tray.setScale(SIMD3(0.10, 0.10, 0.10), relativeTo: nil)
                            tray.position = [0, 0, 0]
                            tray.components.set(PhysicsBodyComponent(shapes:[shapeRes], mass: 1.0, mode: .static))
                            tray.components.set(CollisionComponent(shapes: [shapeRes],isStatic: true))
                            tray.collision?.mode = .colliding
                            tray.physicsBody?.isContinuousCollisionDetectionEnabled = true
                            anchor.addChild(tray)
                        }
                    }
                    Task {
                        if let cover = try? await ModelEntity(named: "DiceCover") {
                            let shapeRes: ShapeResource = try await ShapeResource.generateStaticMesh(from: cover.model?.mesh ?? .generateBox(size: 1.0))
                            cover.name = "cover"
                            cover.setScale(SIMD3(0.10, 0.10, 0.10), relativeTo: nil)
                            cover.position = [0, 0.008, 0]
                            cover.model?.materials[0] = SimpleMaterial(color: .clear, roughness: 0.5, isMetallic: false)
                            cover.components.set(PhysicsBodyComponent(shapes:[shapeRes], mass: 1.0, mode: .static))
                            cover.components.set(CollisionComponent(shapes: [shapeRes],isStatic: true))
                            cover.collision?.mode = .colliding
                            cover.physicsBody?.isContinuousCollisionDetectionEnabled = true
                            anchor.addChild(cover)
                        }
                    }
                    content.add(anchor)
                    diceData.addDice(content: &content)
                    content.camera = .spatialTracking
                    
                } update: { content in
                    if hasRolled {
                        diceData.rollDice(content: &content)
                    }
                    if changeDie {
                        diceData.removeDice(content: &content)
                        diceData.addDice(content: &content)
                    }
                    if changeDieSkin {
                        diceData.changeSkin(content: &content)
                    }
                    
                } placeholder: {
                    ProgressView()
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
//                            showSkinOptions.toggle()
                            changeDieSkin.toggle()
                        }.buttonStyle(.bordered).padding(30)
                        Spacer()
                        Button("Change\n Dice") {
                            showDiceOptions.toggle()
                        }.buttonStyle(.bordered).padding(30)
                    }
                    HStack {
                        NavigationLink(destination: Store()) {
                            Image(systemName: "storefront").font(.largeTitle)
                        }
                        Button("\(Image("WoodDie"))") {
//                            print("rolling")
                            hasRolled.toggle()
                            diceData.dice_position = [0, 0.1, 0.08]
                        }.frame(height: 80).scaledToFit()
                            .padding(.horizontal, 30)
                        NavigationLink(destination: DetailView()) {
                            Image("skins").font(.largeTitle)
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
