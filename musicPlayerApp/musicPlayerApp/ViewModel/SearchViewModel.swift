//
//  SearchViewModel.swift
//  musicPlayerApp
//
//  Created by Nursultan Kabulov on 19.07.2024.
//

import Foundation

final class SearchViewModel {

	var network = NetworkManager.shared
	var trackPoster: Observable<UIImage> = Observable(nil)
	var items: Observable<[Item]> = Observable(nil)

	init(_ view: SPTAppRemoteDelegate) {
		self.network.appRemote.delegate = view
	}

	func authForSearch() {
		network.getTokenForSearch()
	}

	func getPoster(for track: SPTAppRemoteImageRepresentable) {
		network.fetchArtwork(for: track) { image in
			self.trackPoster.value = image
		}
	}

	func getCount() -> Int {
		guard let count = self.items.value?.count else { return 0 }
		return count
	}

	func search(_ name: String) {
		network.search(byName: name) { result in
			self.items.value = result.tracks.items
		}
	}
}
