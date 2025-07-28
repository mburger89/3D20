//
//  _3Dexp.swift
//  3D20
//
//  Created by Anson Burger on 7/27/25.
//

import SwiftUI
import RealityKit

struct _3Dexp: View {
    @State var diceData: DiceData
    var body: some View {
        ZStack {
            RealityView { content in
                content.camera = .virtual

                let anchor = Entity()
                anchor.name = "dice_anchor"
                content.add(anchor)
                let light = SpotLight()
                light.position = [0, 5, 0]
                light.isEnabled = true
                content.add(light)
                diceData.addTray(content: &content)
                diceData.addCover(content: &content)
                diceData.addDice(content: &content)
               if let box = content.entities.first(where: {$0.name == "dice_anchor"}) {
                   box.setScale([3,3,3], relativeTo: nil)
                   box.position = [0,-0.3,0]
                }
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
            .sheet(isPresented: $diceData.showSkinOptions, onDismiss: {}) {
                Text("Skins Coming Soon...")
            }
//            MARK: The HUD
            HUDControls(diceData: diceData)
            
        }.edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    _3Dexp(diceData: DiceData())
}
