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
	var playerState: Observable<SPTAppRemotePlayerState> = Observable(nil)

	init(_ view: SPTAppRemoteDelegate) {
		self.network.appRemote.delegate = view
	}

	func getPoster(for track: SPTAppRemoteImageRepresentable) {
		network.fetchArtwork(for: track) { image in
			self.trackPoster.value = image
		}
	}

	func playMusic(_ track: SPTAppRemoteContentItem) {
		network.play(item: track)
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
	}

	func next() {
		network.next { playerState in
			self.playerState.value = playerState
		}
	}

	func previous() {
		network.previous { playerState in
			self.playerState.value = playerState
		}
	}

	func seekToPosition(_ value: Int) {
		network.seekToPosition(value)
	}

	func shuffle(_ isShuffeled: Bool) {
		network.shuffle(isShuffeled) { playerState in
			self.playerState.value = playerState
		}
	}

	func repeatMode(_ option: SPTAppRemotePlaybackOptionsRepeatMode) {
		network.repeatMode(option)
	}

	func addToLibrary(uri: String) {
		network.addToLibraryWith(uri: uri)

	}

	func removeFromLibrary(uri: String) {
		network.removeFromLibrary(uri: uri)
	}
}
