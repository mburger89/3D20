//
//  DiceSkins.swift
//  3D20
//
//  Created by Anson Burger on 7/5/25.
//

import SwiftUI

struct DiceSkins: View {
    @Environment(\.dismiss) var dismiss
    @Binding var dD: DiceData
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(),GridItem(),GridItem()]) {
                ForEach(skinData, id: \.self) { die in
                    Button(action: {dD.skin = die; dismiss() }) {
                        Image(die)
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.secondary)
                    }
                }
            }.padding(.horizontal, 20)
        }.padding(.top, 20)
//   end view
    }
}

#Preview {
    DiceSkins(dD: .constant(DiceData()))
}
