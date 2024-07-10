//
//  LogInViewModel.swift
//  musicPlayerApp
//
//  Created by Nursultan Kabulov on 09.07.2024.
//

import UIKit

final class LogInViewModel {
	
	var network = NetworkManager.shared
	var trackPoster: Observable<UIImage> = Observable(nil)
	var playerState: Observable<SPTAppRemotePlayerState> = Observable(nil)
	
	init(_ view: SPTAppRemoteDelegate) {
		self.network.appRemote.delegate = view
	}
	
	func getPoster(for track: SPTAppRemoteTrack) {
		network.fetchArtwork(for: track) { image in
			self.trackPoster.value = image
		}
	}

	func getPlayerState() {
		network.fetchPlayerState { playerState in
			self.playerState.value = playerState
		}
	}

	func setImage() -> UIImage {
		guard let image = trackPoster.value else { return UIImage(systemName: "music.note") ?? UIImage() }
		return image
	}

	func setPlayerState() -> SPTAppRemotePlayerState? {
		guard let playerState = playerState.value else { return nil }
		return playerState
	}
}
