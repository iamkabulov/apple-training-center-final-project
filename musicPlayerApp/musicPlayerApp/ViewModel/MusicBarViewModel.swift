//
//  MusicBarViewModel.swift
//  musicPlayerApp
//
//  Created by Nursultan Kabulov on 18.07.2024.
//

import Foundation

final class MusicBarViewModel {

	var network = NetworkManager.shared
	var trackPoster: Observable<UIImage> = Observable(nil)
	var playerState: Observable<SPTAppRemotePlayerState> = Observable(nil)

	init(_ view: SPTAppRemoteDelegate) {
		self.network.appRemote.delegate = view
	}

	func getPoster(for track: SPTAppRemoteImageRepresentable) {
		network.fetchArtwork(for: track) { image in
			self.trackPoster.value = image
		}
	}

	func getPlayerState() {
		network.fetchPlayerState { playerState in
			self.playerState.value = playerState
		}
	}

	func subscribeToState() {
		network.subscribeToState { playerState in
			self.playerState.value = playerState
		}
	}

	func play() {
		network.play()
	}

	func pause() {
		network.pause()
	}
}
