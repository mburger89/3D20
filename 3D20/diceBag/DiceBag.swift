//
//  DiceBag.swift
//  3D20
//
//  Created by Anson Burger on 7/5/25.
//

import SwiftUI

struct DiceView: View {
	@Environment(DiceData.self) var dd
	var body: some View {
		ScrollView {
			LazyVGrid(columns: [GridItem(), GridItem()]) {
				ForEach(dd.skinData.dice, id: \.name) { skin in
					NavigationLink(destination: DetailView(skinData: skin)) {
						DiceSkin(diceName: skin.name, displayName: skin.displayName)
					}
				}
			}.padding(.horizontal, 10)
		}
	}
}
#Preview("Die Skins") {
	DiceView()
		.environment(DiceData())
}

struct TrayView: View {
	@Environment(DiceData.self) var dd
	var body: some View {
		ScrollView {
			LazyVGrid(columns: [GridItem(), GridItem()]) {
				ForEach(dd.skinData.trays, id: \.name) { skin in
					NavigationLink(destination: TrayDetailView(skinData: skin)) {
						TraySkin(diceName: skin.name, displayName: skin.displayName)
					}
				}
			}.padding(.horizontal, 10)
		}
	}
}
#Preview("Tray Skins") {
	TrayView()
		.environment(DiceData())
}


struct DiceBag: View {
	@State private var selection: Int? = 0
	var body: some View {
		TabView(selection: $selection) {
			Tab("Dice", systemImage: "dice.fill", value: 0) {
				DiceView()
			}
			Tab("Tray", systemImage: "tray.fill", value: 1) {
				TrayView()
			}
		}.navigationTitle("Dice bag")
	}
}

#Preview {
	DiceBag()
}
