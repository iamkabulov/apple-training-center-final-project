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
	var poster: Observable<UIImage> = Observable(nil)
	var libraryStates: ObservableDictionary<String, SPTAppRemoteLibraryState> = ObservableDictionary()
	var isAdded: Observable<Bool> = Observable(false)
	var isRemoved: Observable<Bool> = Observable(false)
	var playerState: Observable<SPTAppRemotePlayerState> = Observable(nil)

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

	func addToLibrary(uri: String) {
		network.addToLibraryWith(uri: uri)
		self.libraryStates.removeValue(forKey: uri)
		self.getTrackState(uri: uri)
		self.isAdded.value = false

	}

	func removeFromLibrary(uri: String) {
		network.removeFromLibrary(uri: uri)
		self.libraryStates.removeValue(forKey: uri)
		self.getTrackState(uri: uri)
		self.isRemoved.value = false
	}

	func getTrackState(uri: String) {
		if let _ = libraryStates[uri] {
			return
		}

		network.getTrackState(uri: uri) { libraryState in
			self.libraryStates.updateValue(libraryState, forKey: uri)
		}
	}

	func play(trackUri uri: String) {
		network.play(trackUri: uri)
	}

	func subscribeToState() {
		network.subscribeToState { playerState in
			self.playerState.value = playerState
		}
	}
}
