//
//  FaceControls.swift
//  3D20
//
//  Created by Anson Burger on 7/27/25.
//

import SwiftUI
import UIKit

struct HUDControls: View {
	@Environment(DiceData.self) var db
	var body: some View {
		@Bindable var diceData: DiceData = db
		VStack {
			Picker("ViewMode", selection: $diceData.arExp){
				Text("3D").tag(false)
				Text("AR").tag(true)
			}.pickerStyle(.segmented)
				.glassEffect()
				.frame(width: 200, height: 200)
			
			Spacer()
			HStack {
				Button("Change\n Skin") {
					diceData.showSkinOptions.toggle()
				}
				.buttonBorderShape(.capsule)
				.padding(10)
				.glassEffect()
				.accessibilityIdentifier("change-skin-button")
				Spacer()
				Button("Change\n Dice") {
					diceData.showDiceOptions.toggle()
				}
				.buttonBorderShape(.capsule)
				.padding(10)
				.glassEffect()
				.accessibilityIdentifier("change-dice-button")
			}
			.padding(.bottom, 25)
			.padding(.horizontal, 20)
			HStack {
				NavigationLink(destination: Store()) {
					Image(systemName: "storefront").font(.largeTitle)
						.padding(15)
						.glassEffect()
						.padding(.leading, 5)
				}
				.accessibilityIdentifier("store-link")
				Button {
					UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
					diceData.hasRolled.toggle()
					diceData.dice_position = [0, 0.15, 0.0]
				} label: { Image("WoodDie") }
					.frame(height: 80).scaledToFit()
					.padding(.horizontal, 30)
					.accessibilityIdentifier("roll-button")
				NavigationLink(destination: DiceBag()) {
					Image("dice.skins")
						.scaleEffect(3.0)
						.padding(30)
					
						.glassEffect()
					
				}
				.accessibilityIdentifier("dicebag-link")
			}.padding(.bottom, 50).padding(.horizontal, 10)
		}
	}
}

#Preview {
	HUDControls()
}
