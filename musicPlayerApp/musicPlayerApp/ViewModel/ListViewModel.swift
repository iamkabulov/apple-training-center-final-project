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
}
