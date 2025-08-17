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
                Text("3D").tag(false)
                Text("AR").tag(true)
            }.pickerStyle(.segmented)
                .frame(width: 200, height: 200)
            Spacer()
            HStack {
                Button("Change\n Skin") {
                    diceData.showSkinOptions.toggle()
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
                    diceData.dice_position = [0, 0.15, 0.0]
                }.frame(height: 80).scaledToFit()
                    .padding(.horizontal, 30)
                NavigationLink(destination: DiceBag()) {
                    Image("dice.skins")
                        .scaleEffect(3.0)
                        .padding(.top,10)
                        .padding(.horizontal, 10)
                }
            }.padding(.bottom, 50)
        }
    }
}

#Preview {
    HUDControls(diceData: DiceData())
}
