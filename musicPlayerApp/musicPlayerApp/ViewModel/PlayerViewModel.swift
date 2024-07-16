//
//  PlayerViewModel.swift
//  musicPlayerApp
//
//  Created by Nursultan Kabulov on 15.07.2024.
//

import Foundation

final class PlayerViewModel {

	var network = NetworkManager.shared
	var trackPoster: Observable<UIImage> = Observable(nil)
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

	func playMusic(_ track: SPTAppRemoteContentItem) {
		network.play(track)
	}

	func getPlayerState() {
		network.fetchPlayerState { playerState in
			guard let playerState = playerState else { return }
			self.playerState.value = playerState
		}
	}

	func play() {
		network.play()
	}

	func pause() {
		network.pause()
	}

	func subscribeToState() {
		network.subscribeToState { playerState in
			self.playerState.value = playerState
		}
		network.appRemote.playerAPI?.setShuffle(false)
	}
}
