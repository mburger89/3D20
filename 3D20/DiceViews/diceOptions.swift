//
//  diceOptions.swift
//  3D20
//
//  Created by Anson Burger on 7/2/25.
//

import SwiftUI

struct diceOptions: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var diceData: DiceData
    var body: some View {
        Grid(horizontalSpacing: 20, verticalSpacing: 20){
            GridRow{
                Button(action: {diceData.dice_type = "D04"; dismiss()}){
                    Image("D04").resizable().scaledToFit()
                }.frame(width: 100, height: 100)
                Button(action:{diceData.dice_type = "D06"; dismiss()}) {
                    Image("D06").resizable().scaledToFit()
                }.frame(width: 100, height: 100)
                Button(action: {diceData.dice_type = "D08"; dismiss()}) {
                    Image("D08").resizable().scaledToFit()
                }.frame(width: 100, height: 100)
            }
            GridRow{
                Button(action: {diceData.dice_type = "D10"; dismiss()}){
                    Image("D10").resizable().scaledToFit()
                }.frame(width: 100, height: 100)
                Button(action: {diceData.dice_type = "D12"; dismiss()}) {
                    Image("D12").resizable().scaledToFit()
                }.frame(width: 100, height: 100)
                Button(action: {diceData.dice_type = "D20"; dismiss()}) {
                    Image("D20").resizable().scaledToFit()
                }.frame(width: 100, height: 100)
            }
        }
    }
}

#Preview {
    diceOptions(diceData: .constant(DiceData()))
}
