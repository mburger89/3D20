//
//  DiceSkins.swift
//  3D20
//
//  Created by Anson Burger on 7/5/25.
//

import SwiftUI

struct Skins: View {
    @Environment(\.dismiss) var dismiss
    var dD: DiceData
    @State var dort: Bool = true
    var body: some View {
        Picker("skinSelection", selection: $dort) {
            Text("Dice").tag(true)
            Text("Tray").tag(false)
        }.pickerStyle(.segmented).padding(.top, 10).padding(.horizontal, 8)
        if dort {
            ScrollView {
                LazyVGrid(columns: [GridItem(),GridItem(),GridItem()]) {
                    ForEach(SDArray, id: \.id) { die in
                        Button(action: {dD.skin = die.name; dismiss() }) {
                            Image(die.name)
                                .resizable()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding(.top, 20).padding(.horizontal, 20)
            .onDisappear(perform: {dD.changeDieSkin.toggle()})
        } else {
            ScrollView {
                LazyVGrid(columns: [GridItem(),GridItem(),GridItem()]) {
                    ForEach(traySkins, id: \.id) { t in
                        Button(action: {dD.traySkin = t.name; dismiss() }) {
//                            Image(t.name)
//                                .resizable()
//                                .frame(width: 100, height: 100)
//                                .foregroundColor(.secondary)
                            Text(t.name)
                        }
                    }
                }
            }
            .padding(.top, 20)
            .padding(.horizontal, 20)
            .onDisappear(perform: {dD.changeTraySkin.toggle()})
        }
        
//   end view
    }
}

#Preview {
    Skins(dD: DiceData())
}

