//
//  TrackEntity.swift
//  musicPlayerApp
//
//  Created by Nursultan Kabulov on 19.07.2024.
//

import Foundation

// MARK: - TrackEntity
struct TrackEntity: Codable {
	let tracks: Tracks

	enum CodingKeys: String, CodingKey {
		case tracks
	}
}

// MARK: - Tracks
struct Tracks: Codable {
	let href: String?
	let limit: Int?
	let next: String?
	let offset: Int?
	let previous: String?
	let total: Int?
	let items: [Item]
}

// MARK: - Item
struct Item: Codable {
	let album: Album?
	let artists: [Artist]?
	let discNumber, durationMS: Int?
	let explicit: Bool?
	let externalIDS: ExternalIDS?
	let externalUrls: ExternalUrls?
	let href: String?
	let id: String?
	let isPlayable: Bool?
	let name: String?
	let popularity: Int?
	let previewURL: String?
	let trackNumber: Int?
	let type: ItemType?
	let uri: String
	let isLocal: Bool?

	enum CodingKeys: String, CodingKey {
		case album, artists
		case discNumber = "disc_number"
		case durationMS = "duration_ms"
		case explicit
		case externalIDS = "external_ids"
		case externalUrls = "external_urls"
		case href, id
		case isPlayable = "is_playable"
		case name, popularity
		case previewURL = "preview_url"
		case trackNumber = "track_number"
		case type, uri
		case isLocal = "is_local"
	}
}

// MARK: - Album
struct Album: Codable {
	let albumType: AlbumTypeEnum?
	let totalTracks: Int?
	let externalUrls: ExternalUrls?
	let href: String?
	let id: String?
	let images: [Image]?
	let name, releaseDate: String?
	let releaseDatePrecision: ReleaseDatePrecision?
	let type: AlbumTypeEnum?
	let uri: String?
	let artists: [Artist]?
	let isPlayable: Bool?

	enum CodingKeys: String, CodingKey {
		case albumType = "album_type"
		case totalTracks = "total_tracks"
		case externalUrls = "external_urls"
		case href, id, images, name
		case releaseDate = "release_date"
		case releaseDatePrecision = "release_date_precision"
		case type, uri, artists
		case isPlayable = "is_playable"
	}
}

enum AlbumTypeEnum: String, Codable {
	case album = "album"
	case single = "single"
	case compilation = "compilation"
}

// MARK: - Artist
struct Artist: Codable {
	let externalUrls: ExternalUrls?
	let href: String?
	let id, name: String
	let type: ArtistType?
	let uri: String?

	enum CodingKeys: String, CodingKey {
		case externalUrls = "external_urls"
		case href, id, name, type, uri
	}
}

// MARK: - ExternalUrls
struct ExternalUrls: Codable {
	let spotify: String
}

enum ArtistType: String, Codable {
	case artist = "artist"
}

// MARK: - Image
struct Image: Codable {
	let url: String
	let height, width: Int?
}

enum ReleaseDatePrecision: String, Codable {
	case day = "day"
	case year = "year"
}

// MARK: - ExternalIDS
struct ExternalIDS: Codable {
	let isrc: String
}

enum ItemType: String, Codable {
	case track = "track"
}
