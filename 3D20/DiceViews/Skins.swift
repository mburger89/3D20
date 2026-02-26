//
//  DiceSkins.swift
//  3D20
//
//  Created by Anson Burger on 7/5/25.
//

import SwiftUI

struct Skins: View {
	@Environment(\.dismiss) var dismiss
	@Environment(DiceData.self) var diceData: DiceData
	@State var dort: Bool = true
	var body: some View {
		@Bindable var dD = diceData
		Picker("skinSelection", selection: $dort) {
			Text("Dice").tag(true)
			Text("Tray").tag(false)
		}.pickerStyle(.segmented).padding(.top, 10).padding(.horizontal, 8)
		if dort {
			ScrollView {
				LazyVGrid(columns: [GridItem(),GridItem(),GridItem()]) {
					ForEach(diceData.skinData.dice, id: \.name) { die in
						Button {
							dD.skin = die.name;
							dD.changeDieSkin.toggle();
							dismiss()
						} label: {
							Image(die.name)
								.resizable()
								.frame(width: 100, height: 100)
								.foregroundColor(.secondary)
						}
					}
				}
			}
			.padding(.top, 20).padding(.horizontal, 20)
		} else {
			ScrollView {
				LazyVGrid(columns: [GridItem(),GridItem(),GridItem()]) {
					ForEach(diceData.skinData.trays, id: \.name) { t in
						Button(action: {
							dD.traySkin = t.name;
							dD.changeTraySkin.toggle();
							dismiss()
						}) {
							Image("tray_\(t.name)")
								.resizable()
								.aspectRatio(contentMode: .fill)
								.frame(width: 120, height: 80)
								.foregroundColor(.secondary)
							
						}
					}
				}
			}
			.padding(.top, 20)
			.padding(.horizontal, 20)
		}
		
		//   end view
	}
}

#Preview {
	Skins()
}

