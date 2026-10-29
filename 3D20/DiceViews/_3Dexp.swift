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

				// Default camera: 15° tilt down from horizontal for a dramatic side-on view
				let cameraEntity = Entity()
				cameraEntity.components.set(PerspectiveCameraComponent())
				// From [0, 0.06, 0.97] looking at [0, -0.2, 0] ≈ 15° below horizontal
				cameraEntity.look(at: SIMD3<Float>(0, -0.2, 0),
				                  from: SIMD3<Float>(0, 0.40, 2.17),
				                  relativeTo: nil)
				content.add(cameraEntity)

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
				if diceData.hasRolled {
					diceData.hasRolled = false
				} else {
					// hasRolled just reset to false — impulse was applied, start watching for settle
					diceData.startSettlementDetection()
				}
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

			// Loading overlay — blocks interaction until the die model is fully in the scene
			if !diceData.isDieReady {
				VStack {
					Spacer()
					ProgressView()
						.tint(.white)
						.scaleEffect(1.4)
						.padding(20)
						.glassEffect(in: .circle)
					Spacer()
				}
				.allowsHitTesting(true)
				.transition(.opacity)
			}

			// Settled roll result — appears with spring animation, clears on next roll
			if let value = diceData.settledFaceValue {
				VStack {
					Text("\(value)")
						.font(.system(size: 72, weight: .bold, design: .rounded))
						.foregroundStyle(.primary)
						.padding(.horizontal, 32)
						.padding(.vertical, 14)
						.glassEffect(in: .capsule)
						.padding(.top, 60)
					Spacer()
				}
				.transition(.scale(scale: 0.8).combined(with: .opacity))
				.allowsHitTesting(false)
			}
		}.edgesIgnoringSafeArea(.all)
	}
}

#Preview {
	_3Dexp(diceData: DiceData())
}
