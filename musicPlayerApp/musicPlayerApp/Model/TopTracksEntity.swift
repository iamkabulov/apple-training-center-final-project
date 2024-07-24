//
//  TopTracksEntity.swift
//  musicPlayerApp
//
//  Created by Nursultan Kabulov on 24.07.2024.
//

import Foundation

struct TopTracksEntity: Codable {
	let tracks: [TopTrack]
}

// MARK: - Track
struct TopTrack: Codable {
	let album: Album?
	let artists: [Artist]?
	let availableMarkets: [String]?
	let discNumber, durationMS: Int?
	let explicit: Bool?
	let externalIDS: ExternalIDS?
	let externalUrls: ExternalUrls?
	let href, id: String?
	let isPlayable: Bool?
	let linkedFrom: LinkedFrom?
	let restrictions: Restrictions?
	let name: String?
	let popularity: Int?
	let previewURL: String?
	let trackNumber: Int?
	let type, uri: String
	let isLocal: Bool?

	enum CodingKeys: String, CodingKey {
		case album, artists
		case availableMarkets = "available_markets"
		case discNumber = "disc_number"
		case durationMS = "duration_ms"
		case explicit
		case externalIDS = "external_ids"
		case externalUrls = "external_urls"
		case href, id
		case isPlayable = "is_playable"
		case linkedFrom = "linked_from"
		case restrictions, name, popularity
		case previewURL = "preview_url"
		case trackNumber = "track_number"
		case type, uri
		case isLocal = "is_local"
	}
}

// MARK: - Album
struct TopAlbum: Codable {
	let albumType: String?
	let totalTracks: Int?
	let availableMarkets: [String]?
	let externalUrls: ExternalUrls?
	let href, id: String?
	let images: [Image]?
	let name, releaseDate, releaseDatePrecision: String?
	let restrictions: Restrictions?
	let type, uri: String?
	let artists: [Artist]?

	enum CodingKeys: String, CodingKey {
		case albumType = "album_type"
		case totalTracks = "total_tracks"
		case availableMarkets = "available_markets"
		case externalUrls = "external_urls"
		case href, id, images, name
		case releaseDate = "release_date"
		case releaseDatePrecision = "release_date_precision"
		case restrictions, type, uri, artists
	}
}

// MARK: - Artist
struct TopArtist: Codable {
	let externalUrls: ExternalUrls?
	let href, id, name, type: String?
	let uri: String?

	enum CodingKeys: String, CodingKey {
		case externalUrls = "external_urls"
		case href, id, name, type, uri
	}
}

// MARK: - Restrictions
struct Restrictions: Codable {
	let reason: String?
}

// MARK: - LinkedFrom
struct LinkedFrom: Codable {
}
