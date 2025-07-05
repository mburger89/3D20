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
                Button("D04"){
                    diceData.dice_type = "D04"
                }.frame(width: 100, height: 100)
                Button("D06") {
                    diceData.dice_type = "D06"
                }.frame(width: 100, height: 100)
                Button("D08") {
                    diceData.dice_type = "D08"
                }.frame(width: 100, height: 100)
            }
            GridRow{
                Button("D10"){
                    diceData.dice_type = "D10"
                }.frame(width: 100, height: 100)
                Button("D12") {
                    diceData.dice_type = "D12"
                }.frame(width: 100, height: 100)
                Button("D20") {
                    diceData.dice_type = "D20"
                }.frame(width: 100, height: 100)
            }
        }
        HStack{
            Button("Change to \(diceData.dice_type)") {
                dismiss()
            }
        }
    }
}

#Preview {
    diceOptions(diceData: .constant(DiceData()))
}
