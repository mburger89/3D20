//
//  DetailView.swift
//  3D20
//
//  Created by Anson Burger on 7/5/25.
//
import Foundation
import SwiftUI
import RealityKit

struct DetailView: View {
    let diceArray: [(String, SIMD3<Float>)] = [
        ("D20", [0.0, 0.0, 0.0]),
        ("D12", [1.5, 0.0, 0.0]),
        ("D10", [3.0, 0.0, 0.0]),
        ("D08", [4.5, 0.0, 0.0]),
        ("D06", [6.0, 0.0, 0.0]),
        ("D04", [7.5, 0.0, 0.0])
    ]
    @State var selectedMode: Int = 0
    
    var body: some View {
        VStack {
            if selectedMode == 0 {
                RealityView { content in
                    content.camera = .virtual
                    do {
                        let die = try await ModelEntity(named: "D20")
                        die.scale = [0.6, 0.6, 0.6]
                        die.position = [0.0, 0.0, 0.0]
                        die.name = "D20"
                        die.components.set(SpinComponent())
                        content.add(die)
                    } catch {
                            print(error)
                    }
                    
                } update: { content in
//                    if let die = content.entities.first(where: {$0.name == "D20"}) {
//                    
//                    }
                }
                .realityViewCameraControls(.pan)
                .frame(maxHeight: 400)
                .background(.ultraThinMaterial)
            } else {
                RealityView { content in
                    content.camera = .virtual
                        for dice in diceArray {
                            do {
                                let die = try await ModelEntity(named: dice.0)
                                die.scale = [0.6, 0.6, 0.6]
                                die.position = dice.1
                                die.name = dice.0
                                content.add(die)
                            } catch {
                                print(error)
                            }
                        }
    //            end of reality view
                } placeholder: {
                    VStack(alignment: .center){
                       Spacer()
                       HStack(alignment: .center) {
                           Spacer()
                           ProgressView().scaleEffect(CGFloat(5.0))
                           Spacer()
                       }
                       Spacer()
                    }
                }
                .realityViewCameraControls(.pan)
                .frame(maxHeight: 400)
                .background(.ultraThinMaterial)
            }
            VStack{
                Picker("Mode", selection: $selectedMode) {
                    Text("Solo").tag(0)
                    Text("Group").tag(1)
                }.pickerStyle(.segmented).padding(.top, 10)
                Text("Dice Data Goes Here").padding(.top, 20)
                Spacer()
            }
            .frame(width: 400)

        }
    }
}

#Preview {
    DetailView()
}
