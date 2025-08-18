//
//  DetailView.swift
//  3D20
//
//  Created by Anson Burger on 7/5/25.
//
import Foundation
import SwiftUI
import RealityKit
import DiceEnv

struct DetailView: View {
    var skinData: SD
    
    private let diceArray: [(String, SIMD3<Float>)] = [
        ("D20", [0.0, 0.0, 0.0]),
        ("D12", [1.5, 0.0, 0.0]),
        ("D10", [3.0, 0.0, 0.0]),
        ("D08", [4.5, 0.0, 0.0]),
        ("D06", [6.0, 0.0, 0.0]),
        ("D04", [7.5, 0.0, 0.0])
    ]
    @State private var selectedMode: Int = 0
    @State private var changeDie: Bool = false
    @State var diceName: String = "D20"
    let dscale: SIMD3<Float> = [0.8, 0.8, 0.8]
    let dposition: SIMD3<Float> = [0.0, 0.0, 0.0]
    var body: some View {
        VStack {
            if selectedMode == 0 {
                RealityView { content in
                    content.camera = .virtual
                    content.renderingEffects.motionBlur = .disabled
                    content.renderingEffects.depthOfField = .disabled
                    
                    let ent = Entity()
                    ent.name = "container"
                    do {
                        let material: ShaderGraphMaterial = try await ShaderGraphMaterial(
                            named: "/Root/\(skinData.name)/\(skinData.name)_\(diceName)",
                            from: "Scene.usda",
                            in: DiceEnv.diceEnvBundle
                        )
                        let die = try await ModelEntity(named: diceName)
                        die.scale = dscale
                        die.position = dposition
                        die.name = "die"
                        die.model?.materials[0] = material
                        die.components.set(SpinComponent())
                        ent.addChild(die)
                    } catch {
                        print(error)
                    }
                    content.add(ent)
                } update: { content in
                    if let current_die = content.entities.first(where: {$0.name == "container"}) {
                        if let die_entity = current_die.children.first(where: {$0.children.count == 0}) {
                            current_die.removeChild(die_entity)
                        }
                        Task {
                            let material: ShaderGraphMaterial = try await ShaderGraphMaterial(
                                named: "/Root/\(skinData.name)/\(skinData.name)_\(diceName)",
                                from: "Scene.usda",
                                in: DiceEnv.diceEnvBundle
                            )
                            let die_temp = try await ModelEntity(named: diceName)
                            die_temp.scale = dscale
                            die_temp.position = dposition
                            die_temp.name = "die"
                            die_temp.model?.materials[0] = material
                            die_temp.components.set(SpinComponent())
                            current_die.addChild(die_temp)
                        }
                    }
                } placeholder: {
                    VStack(alignment: .center){
                        Spacer()
                        HStack(alignment: .center) {
                            Spacer()
                            ProgressView().scaleEffect(CGFloat(3.0))
                            Spacer()
                        }
                        Spacer()
                    }
                }
                .realityViewCameraControls(.orbit)
                .frame(maxHeight: 400)
                .background(.ultraThinMaterial)
            } else {
                RealityView { content in
                    content.camera = .virtual
                    content.renderingEffects.motionBlur = .disabled
                    content.renderingEffects.depthOfField = .disabled
                    for dice in diceArray {
                        do {
                            let material: ShaderGraphMaterial = try await ShaderGraphMaterial(
                                named: "/Root/\(skinData.name)/\(skinData.name)_\(dice.0)",
                                from: "Scene.usda",
                                in: DiceEnv.diceEnvBundle
                            )
                            let die = try await ModelEntity(named: dice.0)
                            die.scale = [0.6, 0.6, 0.6]
                            die.position = dice.1
                            die.name = dice.0
                            die.model?.materials[0] = material
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
                            ProgressView().scaleEffect(CGFloat(3.0))
                            Spacer()
                        }
                        Spacer()
                    }
                }
                .realityViewCameraControls(.pan)
                .frame(maxHeight: 400)
                .background(.ultraThinMaterial)
            }
            VStack( alignment: .leading){
                Picker("Mode", selection: $selectedMode) {
                    Text("Solo").tag(0)
                    Text("Group").tag(1)
                }.pickerStyle(.segmented).padding(.top, 10)
                if selectedMode == 0 {
                    Picker("Die", selection: $diceName) {
                        ForEach(diceArray, id: \.0) {die in
                            Text(die.0).tag(die.0)
                        }
                    }.pickerStyle(.segmented).padding(.top, 10)
                }
                VStack (alignment: .leading) {
                    Text(skinData.displayName).font(.largeTitle).bold()
                    Text(skinData.description).padding(.top, 10)
                }
                .padding(15)
                .frame(width: 360)
                .background(.ultraThinMaterial)
                .mask(RoundedRectangle(cornerRadius: 20))
                .padding(.top, 20)
                Spacer()
            }.padding(.horizontal, 20)
        }
    }
}

#Preview {
    DetailView(skinData: SD(name: "SteelDarkAged", displayName: "Aged Steel", description: "Aged Steel is a durable, dark-colored metal that is well used"))
}
