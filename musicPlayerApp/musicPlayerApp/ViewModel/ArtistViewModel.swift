//
//  ArtistViewModel.swift
//  musicPlayerApp
//
//  Created by Nursultan Kabulov on 23.07.2024.
//

import Foundation

final class ArtistViewModel {

	var network = NetworkManager.shared
	var artistPoster: Observable<UIImage> = Observable(nil)
	var details: Observable<ArtistEntity> = Observable(nil)

	init(_ view: SPTAppRemoteDelegate) {
		self.network.appRemote.delegate = view
	}

	func getPoster(url: String) {
		network.fetchArtistImage(url: url) { img in
			self.artistPoster.value = img
		}
	}

	func getArtistDetails(with data: SPTAppRemoteArtist) {
		let components = data.uri.components(separatedBy: ":")
		if components.count > 2 {
			let artistID = components[2]
			network.getArtistDetails(uri: artistID) { details in
				self.details.value = details
			}
		}
	}
}
