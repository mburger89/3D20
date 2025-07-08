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
                            let shapeRes: ShapeResource = try await ShapeResource.generateStaticMesh(from: tray.model?.mesh ?? .generateBox(size: 1.0))
                            tray.name = "tray"
                            tray.setScale(SIMD3(0.010, 0.010, 0.010), relativeTo: nil)
                            tray.position = [0, 0, 0]
                            tray.components.set(PhysicsBodyComponent(shapes:[shapeRes], mass: 1.0, mode: .static))
                            tray.components.set(CollisionComponent(shapes: [shapeRes],isStatic: true))
                            tray.collision?.mode = .colliding
                            tray.physicsBody?.isContinuousCollisionDetectionEnabled = true
                            anchor.addChild(tray)
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
