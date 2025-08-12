//
//  DiceBag.swift
//  3D20
//
//  Created by Anson Burger on 7/5/25.
//

import SwiftUI

struct DiceBag: View {
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                ForEach(SDArray, id: \.id) { skin in
                    NavigationLink(destination: DetailView(skinData: skin)) {
                        DiceSkin(diceName: skin.name, displayName: skin.displayName)
                    }
                }
            }.padding(.horizontal, 10)
        }.navigationTitle("Dice bag")
    }
}

#Preview {
    DiceBag()
}
