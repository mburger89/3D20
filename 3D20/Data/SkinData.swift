//
//  SkinData.swift
//  3D20
//
//  Created by Anson Burger on 7/29/25.
//

import Foundation

struct SD: Codable, Equatable, Hashable {
	var id: UUID?
	let name: String
	var displayName: String = ""
	var description: String = ""
	
	init(name: String, displayName: String? = nil, description: String? = nil) {
		self.id = UUID()
		self.name = name
		self.displayName = displayName ?? name
		self.description = description ?? ""
	}
}

struct SDData: Codable, Hashable {
	var id: UUID?
	let dice: [SD]
	let trays: [SD]
	init() {
		self.id = UUID()
		self.dice = []
		self.trays = []
	}
}
