//
//  ArtistEntity.swift
//  musicPlayerApp
//
//  Created by Nursultan Kabulov on 23.07.2024.
//

import Foundation

// MARK: - Welcome
struct ArtistEntity: Codable {
	let externalUrls: ExternalUrls
	let followers: Followers
	let genres: [String]
	let href: String
	let id: String
	let images: [Image]
	let name: String
	let popularity: Int
	let type, uri: String

	enum CodingKeys: String, CodingKey {
		case externalUrls = "external_urls"
		case followers, genres, href, id, images, name, popularity, type, uri
	}
}

// MARK: - Followers
struct Followers: Codable {
	let href: String?
	let total: Int
}
