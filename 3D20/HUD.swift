//
//  HUD.swift
//  3D20
//
//  Created by Anson Burger on 1/16/25.
//

import SwiftUI
import SceneKit


struct HUD: View {
    

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {print("hello")}){
                    Image(systemName: "gearshape.fill").font(.largeTitle)
                }
                Spacer()
                Button(action:{print("hello")}) {
                    SceneView()
                }
                Spacer()
                Button(action: {print("hello")}) {
                   Image("skins")
                }
                Spacer()
            }
        }
    }
}
#Preview {
    HUD()
}
