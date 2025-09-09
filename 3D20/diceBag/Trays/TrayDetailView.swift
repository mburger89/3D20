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


struct TrayDetailView: View {
    var skinData: SD
    @State private var selectedMode: Int = 0
    @State private var changeDie: Bool = false
    let dscale: SIMD3<Float> = [0.0075, 0.0075, 0.0075]
    let dposition: SIMD3<Float> = [0.0, -0.1, 0.0]
    var body: some View {
        VStack {
                RealityView { content in
                    content.camera = .virtual
                    content.renderingEffects.motionBlur = .disabled
                    content.renderingEffects.depthOfField = .disabled
                    let ent = Entity()
                    ent.name = "container"
                    do {
                        let material: ShaderGraphMaterial = try await ShaderGraphMaterial(
                            named: "/Root/TraySkins/\(skinData.name)_tray",
                            from: "Scene.usda",
                            in: DiceEnv.diceEnvBundle
                        )
                        let die = try await Entity(named: "diceTray", in: DiceEnv.diceEnvBundle)
                            .children[0].children.first as? ModelEntity
                        die?.scale = dscale
                        die?.position = dposition
                        die?.name = "die"
                        die?.model?.materials[0] = material
                        die?.transform.rotation = simd_quatf(angle: Float(0.5), axis:[1,0,0])
//                        die?.components.set(SpinComponent(axis: [0,1,0]))
                        ent.addChild(die ?? Entity())
                    } catch {
                        print(error)
                    }
                    content.add(ent)
                }
            placeholder: {
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
            VStack( alignment: .leading){
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
    TrayDetailView(skinData: SD(name: "steelDarkAged", displayName: "Aged Steel", description: "Aged Steel is a durable, dark-colored metal that is well used"))
}
