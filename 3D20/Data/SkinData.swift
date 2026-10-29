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

	enum CodingKeys: String, CodingKey {
		case id, name, displayName, description
	}

	init(name: String, displayName: String? = nil, description: String? = nil) {
		self.id = UUID()
		self.name = name
		self.displayName = displayName ?? name
		self.description = description ?? ""
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decodeIfPresent(UUID.self, forKey: .id)
		self.name = try container.decode(String.self, forKey: .name)
		let decodedDisplayName = try container.decodeIfPresent(String.self, forKey: .displayName)
		self.displayName = decodedDisplayName ?? name
		self.description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
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
