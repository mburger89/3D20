//
//  FaceControls.swift
//  3D20
//
//  Created by Anson Burger on 7/27/25.
//

import SwiftUI

struct HUDControls: View {
    @State var diceData: DiceData
    var body: some View {
        VStack {
            Picker("ViewMode", selection: $diceData.arExp){
                Text("AR").tag(true)
                Text("3D").tag(false)
            }.pickerStyle(.segmented)
//                .padding(.top, 50)
                .frame(width: 200, height: 200)
            Spacer()
            HStack {
                Button("Change\n Skin") {
//                            showSkinOptions.toggle()
                    diceData.changeDieSkin.toggle()
                }.buttonStyle(.bordered).padding(30)
                Spacer()
                Button("Change\n Dice") {
                    diceData.showDiceOptions.toggle()
                }.buttonStyle(.bordered).padding(30)
            }
            HStack {
                NavigationLink(destination: Store()) {
                    Image(systemName: "storefront").font(.largeTitle)
                }
                Button("\(Image("WoodDie"))") {
                    diceData.hasRolled.toggle()
                    diceData.dice_position = [0, 0.1, 0.08]
                }.frame(height: 80).scaledToFit()
                    .padding(.horizontal, 30)
                NavigationLink(destination: DetailView()) {
                    Image("skins").font(.largeTitle)
                }
            }.padding(.bottom, 50)
        }
    }
}

#Preview {
    HUDControls(diceData: DiceData())
}
