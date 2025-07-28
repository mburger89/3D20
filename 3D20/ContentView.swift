//
//  ContentView.swift
//  3D20
//
//  Created by Anson Burger on 12/3/24.
//


import SwiftUI
import RealityKit

struct ContentView: View {
    @State var diceData: DiceData = DiceData()
    var body: some View {
        NavigationStack {
            if diceData.arExp {
                ARexp(diceData: diceData)
            } else {
                _3Dexp(diceData: diceData)
            }
        }
        
    }
    
}

#Preview {
    ContentView()
}
