//
//  ListViewModel.swift
//  musicPlayerApp
//
//  Created by Nursultan Kabulov on 15.07.2024.
//

import Foundation

final class ListViewModel {

	var network = NetworkManager.shared
	var trackPoster: Observable<UIImage> = Observable(nil)
	var playerPoster: Observable<UIImage> = Observable(nil)
	var childrenOfContent: Observable<[SPTAppRemoteContentItem]> = Observable(nil)
	var playerState: Observable<SPTAppRemotePlayerState> = Observable(nil)
	var libraryStates: ObservableDictionary<String, SPTAppRemoteLibraryState> = ObservableDictionary()
	var item: Observable<SPTAppRemoteContentItem> = Observable(nil)
	var artistPoster: Observable<UIImage> = Observable(nil)
	var details: Observable<ArtistEntity> = Observable(nil)
	var topTracks: Observable<TopTracksEntity> = Observable(nil)
	var isAdded: Observable<Bool> = Observable(false)
	var isRemoved: Observable<Bool> = Observable(false)

	init(_ view: SPTAppRemoteDelegate) {
		self.network.appRemote.delegate = view
	}

	func getPoster(for track: SPTAppRemoteImageRepresentable) {
		network.fetchArtwork(for: track) { image in
			self.trackPoster.value = image
		}
	}

	func getListOf(content: SPTAppRemoteContentItem) {
		network.fetchContentItemChildren(contentItem: content) { items in
			self.childrenOfContent.value = items
		}
	}

	func getItem() {
		network.getFavouriteLibrary { item in
			self.item.value = item
		}
	}

	func getCount() -> Int {
		guard let count = self.childrenOfContent.value?.count else { return 0 }
		return count
	}

	func getPlayerState() {
		network.fetchPlayerState { playerState in
			guard let playerState = playerState else { return }
			self.playerState.value = playerState
		}
	}

	func getPlayerPoster(for track: SPTAppRemoteImageRepresentable) {
		network.fetchArtwork(for: track) { image in
			self.playerPoster.value = image
		}
	}

	func subscribeToState() {
		network.subscribeToState { playerState in
			self.playerState.value = playerState
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

	func play(item: SPTAppRemoteContentItem) {
		network.play(item: item)
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

	func getTopTracks(with data: SPTAppRemoteArtist) {
		let components = data.uri.components(separatedBy: ":")
		if components.count > 2 {
			let artistID = components[2]
			network.getTopTracks(uri: artistID) { tracks in
				self.topTracks.value = tracks
			}
		}
	}
}
