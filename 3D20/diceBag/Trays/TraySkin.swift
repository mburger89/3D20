//
//  DiceSkin.swift
//  3D20
//
//  Created by Anson Burger on 8/8/25.
//

import SwiftUI

struct TraySkin: View {
	var diceName: String
	var displayName: String
	var body: some View {
		ZStack(alignment: .bottomLeading) {
			VStack {
				Spacer()
				Text(displayName).font(.title2)
					.padding()
				
			}.frame(width: 175, height: 110)
				.background(.ultraThinMaterial)
				.mask(RoundedRectangle(cornerRadius: 20))
			VStack{
				Image("tray_\(diceName)")
					.resizable()
					.aspectRatio(contentMode: .fit)
					.scaleEffect(1.5)
					.padding()
					.frame(width: 175, height: 150)
				Spacer()
			}
		}.frame(width: 175, height: 200)
	}
}

#Preview {
	TraySkin(diceName: "steelDarkAged", displayName: "Aged Steel")
}
