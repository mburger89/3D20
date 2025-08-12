//
//  ARexp.swift
//  3D20
//
//  Created by Anson Burger on 7/27/25.
//

import SwiftUI
import RealityKit

struct ARexp: View {
    @State var diceData: DiceData
    var body: some View {
        ZStack {
            RealityView { content in
                content.camera = .spatialTracking
                // Create horizontal plane anchor for the content
                let anchor = AnchorEntity(
                    .plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.001,0.001))
                )
                anchor.name = "dice_anchor"
                content.add(anchor)
                
                diceData.addTray(content: &content)
                diceData.addCover(content: &content)
                diceData.addDice(content: &content)
                
            } update: { content in
                if diceData.hasRolled {
                    diceData.rollDice(content: &content)
                }
                if diceData.changeDie {
                    diceData.removeDice(content: &content)
                    diceData.addDice(content: &content)
                }
                if diceData.changeDieSkin {
                    diceData.changeSkin(content: &content)
                }
                if diceData.changeTraySkin {
                    diceData.changeTraySkin(content: &content)
                }
            } placeholder: {
                ProgressView()
            }
            .realityViewCameraControls(.orbit)
            .onChange(of: diceData.hasRolled) {
                if diceData.hasRolled { diceData.hasRolled = false }
            }
            .onChange(of: diceData.changeDie) {
                if diceData.changeDie { diceData.changeDie = false }
            }
            .sheet(isPresented: $diceData.showDiceOptions, onDismiss: { diceData.changeDie.toggle() }) {
                diceOptions(diceData: $diceData).presentationDetents([.fraction(0.4)])
            }
            .sheet(isPresented: $diceData.showSkinOptions) {
                Skins(dD: diceData).presentationDetents([.fraction(0.4)])
            }
           HUDControls(diceData: diceData)
        }.edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    ARexp(diceData: DiceData())
}
