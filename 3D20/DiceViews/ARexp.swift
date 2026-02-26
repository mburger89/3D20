//
//  ARexp.swift
//  3D20
//
//  Created by Anson Burger on 7/27/25.
//

import SwiftUI
import RealityKit

struct ARexp: View {
	@Environment(DiceData.self) var db
	var body: some View {
		ZStack {
			@Bindable var diceData = db
			RealityView { content in
				content.camera = .spatialTracking
				content.renderingEffects.motionBlur = .disabled
				content.renderingEffects.depthOfField = .disabled
				// Create horizontal plane anchor for the content
				let anchor = AnchorEntity(
					.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.001,0.001))
				)
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
				diceOptions().presentationDetents([.fraction(0.4)])
			}
			.sheet(isPresented: $diceData.showSkinOptions) {
				Skins().presentationDetents([.fraction(0.4)])
			}
			HUDControls()
		}.edgesIgnoringSafeArea(.all)
	}
}

#Preview {
	ARexp()
}
