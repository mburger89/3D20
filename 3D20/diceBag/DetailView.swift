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
    private let diceArray: [(String, SIMD3<Float>)] = [
        ("D20", [0.0, 0.0, 0.0]),
        ("D12", [1.5, 0.0, 0.0]),
        ("D10", [3.0, 0.0, 0.0]),
        ("D08", [4.5, 0.0, 0.0]),
        ("D06", [6.0, 0.0, 0.0]),
        ("D04", [7.5, 0.0, 0.0])
    ]
    @State var diceData: DiceData = DiceData()
    @State private var selectedMode: Int = 0
    @State private var changeDie: Bool = false
    @State var diceName: String = "D20"
    var body: some View {
        VStack {
            if selectedMode == 0 {
                RealityView { content in
                    content.camera = .virtual
                    let ent = Entity()
                    ent.name = "container"
                    do {
                        let die = try await ModelEntity(named: diceName)
                        die.scale = [0.6, 0.6, 0.6]
                        die.position = [0.0, 0.0, 0.0]
                        die.name = "die"
                        die.components.set(SpinComponent())
                        ent.addChild(die)
                    } catch {
                            print(error)
                    }
                    content.add(ent)
                } update: { content in
//                    if changeDie {
                        if let current_die = content.entities.first(where: {$0.name == "container"}) {
                            if let die_entity = current_die.children.first(where: {$0.children.count == 0}) {
                                current_die.removeChild(die_entity)
                            }
                            Task {
                                let die_temp = try await ModelEntity(named: diceName)
                                die_temp.scale = [0.6, 0.6, 0.6]
                                die_temp.position = [0.0, 0.0, 0.0]
                                die_temp.name = "die"
                                die_temp.components.set(SpinComponent())
                                current_die.addChild(die_temp)
                            }
                        }
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
    //          MARK: End of reality view
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
//                .onChange(of: diceData.dice_type) {
//                        changeDie.toggle()
//                    }
            }
            VStack( alignment: .leading){
                Picker("Mode", selection: $selectedMode) {
                    Text("Solo").tag(0)
                    Text("Group").tag(1)
                }.pickerStyle(.segmented).padding(.top, 10).padding(.horizontal, 20)
                if selectedMode == 0 {
                    Picker("Die", selection: $diceName) {
                        ForEach(diceArray, id: \.0) {die in
                            Text(die.0).tag(die.0)
                        }
                    }.pickerStyle(.segmented).padding(.top, 10).padding(.horizontal, 20)
                }
                Text("Dice Data Goes Here").padding(.top, 20).padding(.horizontal, 20)
                Spacer()
            }
            .frame(width: 400)

        }
    }
}

#Preview {
    DetailView()
}
