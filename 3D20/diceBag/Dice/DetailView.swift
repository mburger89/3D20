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
	@Environment(DiceData.self) var db
	@State private var selectedMode: Int = 0
	@State private var changeDie: Bool = false
	@State var diceName: String = "D20"
	@State var updateDie: Bool = false
	let dposition: SIMD3<Float> = [0.0, 0.0, 0.0]
	let dieScale: SIMD3<Float> = [1, 1, 1]
	var skinData: SD
	private let diceArray: [String] = [
		"D20",
		"D12",
		"D10",
		"D100",
		"D08",
		"D06",
		"D04"
	]
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
						let die = try await Entity(named: diceName, in: DiceEnv.diceEnvBundle)
						die.scale = dieScale
						die.position = dposition
						die.name = "die"
						(die.children.first as? ModelEntity)?.model?.materials[0] = material
						die.components.set(SpinComponent())
						ent.addChild(die)
					} catch {
						print(error)
					}
					content.add(ent)
				} update: { content in
					if updateDie {
						if let current_die = content.entities.first(where: {$0.name == "container"}) {
							current_die.removeChild(current_die.children.first!)
							Task {
								let material: ShaderGraphMaterial = try await ShaderGraphMaterial(
									named: "/Root/\(skinData.name)/\(skinData.name)_\(diceName)",
									from: "Scene.usda",
									in: DiceEnv.diceEnvBundle
								)
								let die_temp = try await Entity(named: diceName, in: DiceEnv.diceEnvBundle)
								die_temp.scale = dieScale
								die_temp.position = dposition
								die_temp.name = "die"
								(die_temp.children.first as? ModelEntity)?.model?.materials[0] = material
								die_temp.components.set(SpinComponent())
								current_die.addChild(die_temp)
								updateDie = false
							}
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
					
					do {
						let skins = await loadSkins()
						let diceCol = try await Entity(named: "diceCollection", in: DiceEnv.diceEnvBundle)
						diceCol.scale = [35,35,35]
						diceCol.position = [0.0,-0.5,0.0]
						diceCol.name = "Container"
						diceCol.children[0].children.forEach { die in
							(die as! ModelEntity).model?.materials[0] = skins[die.name] ?? SimpleMaterial()
						}
						content.add(diceCol)
					} catch {
						print(error)
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
				.realityViewCameraControls(.orbit)
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
						ForEach(diceArray, id: \.self) {die in
							Text(die).tag(die)
						}
					}.pickerStyle(.segmented).padding(.top, 10)
						.onChange(of: diceName) {
							updateDie.toggle()
						}
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
	func loadSkins() async -> [String: ShaderGraphMaterial] {
		var skins: [String: ShaderGraphMaterial] = [:]
		for d in diceArray {
			do {
				let material: ShaderGraphMaterial = try await ShaderGraphMaterial(
					named: "/Root/\(skinData.name)/\(skinData.name)_\(d)",
					from: "Scene.usda",
					in: DiceEnv.diceEnvBundle
				)
				skins[d] = material
			} catch {
				print(error)
			}
		}
		return skins
	}
}

#Preview {
	DetailView(skinData: SD(name: "SteelDarkAged", displayName: "Aged Steel", description: "Aged Steel is a durable, dark-colored metal that is well used"))
}
