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
				content.renderingEffects.motionBlur = .disabled
				content.renderingEffects.depthOfField = .disabled
				let anchor = Entity()
				anchor.name = "dice_anchor"
				content.add(anchor)
				
				diceData.addTrayCover(content: &content)
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
				VStack {
					Spacer()
					Text("Loading...")
					ProgressView()
					Spacer()
				}
			}
			.realityViewCameraControls(.orbit)
			.onChange(of: diceData.hasRolled) {
				if diceData.hasRolled { diceData.hasRolled = false }
			}
			.onChange(of: diceData.changeDie) {
				if diceData.changeDie { diceData.changeDie = false }
			}
			.sheet(isPresented: $diceData.showDiceOptions, onDismiss: { diceData.changeDie.toggle() }) {
				diceOptions().presentationDetents([.fraction(0.4)])
			}
			.sheet(isPresented: $diceData.showSkinOptions) {
				Skins().presentationDetents([.fraction(0.4)])
			}
//            MARK: The HUD
			HUDControls()
			
		}.edgesIgnoringSafeArea(.all)
	}
}

#Preview {
	_3Dexp(diceData: DiceData())
}
