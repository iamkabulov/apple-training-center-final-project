//
//  MainViewModel.swift
//  musicPlayerApp
//
//  Created by Nursultan Kabulov on 10.07.2024.
//

import Foundation

final class MainViewModel {

	var network = NetworkManager.shared
	var trackPoster: Observable<UIImage> = Observable(nil)
	var playerState: Observable<SPTAppRemotePlayerState> = Observable(nil)
	var contentItems: Observable<[SPTAppRemoteContentItem]> = Observable(nil)
	var itemPosters: ObservableDictionary<String, UIImage> = ObservableDictionary()
	var childrenOfContent: Observable<[SPTAppRemoteContentItem]> = Observable(nil)

	init(_ view: SPTAppRemoteDelegate) {
		self.network.appRemote.delegate = view
	}

	func getPlayerState() {
		network.fetchPlayerState { playerState in
			self.playerState.value = playerState
		}
	}

	func getContentItems() {
		network.fetchContentItems { contentItems in
			self.contentItems.value = contentItems
		}
	}

	func getPosters(forCellWithID cellID: String, for uri: SPTAppRemoteContentItem?) {
		network.fetchContentItem(uri: uri) { image in
			if let image = image {
				self.itemPosters.updateValue(image, forKey: cellID)
				NotificationCenter.default.post(name: .imageLoaded, object: nil, userInfo: ["cellID": cellID])
			}
		}
	}
}
