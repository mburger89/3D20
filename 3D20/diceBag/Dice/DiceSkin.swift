//
//  DiceSkin.swift
//  3D20
//
//  Created by Anson Burger on 8/8/25.
//

import SwiftUI

struct DiceSkin: View {
	var diceName: String
	var displayName: String
	var body: some View {
		ZStack {
			VStack {
				Spacer()
				Text(displayName).font(.title2).padding(10)
			}
			.frame(width: 175, height: 175)
			.background(.ultraThinMaterial)
			.mask(RoundedRectangle(cornerRadius: 20))
			.padding(.top, 15)
			VStack {
				Image(diceName)
					.resizable()
					.aspectRatio(contentMode: .fit)
					.scaleEffect(1.5)
				Spacer()
			}
			.frame(width: 175, height: 125)
			.padding(.bottom, 60)
		}.frame(width: 175, height: 220)
	}
}

#Preview {
	DiceSkin(diceName: "SteelDarkAged", displayName: "Aged Steel")
}
