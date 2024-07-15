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
	private var imageCache: [String: UIImage] = [:]

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

	func getContentItems() {
		network.fetchContentItems { contentItems in
			self.contentItems.value = contentItems
		}
	}

	func getPosters(forCellWithID cellID: String, for uri: SPTAppRemoteContentItem?) {
		if let cachedImage = imageCache[cellID] {
			self.itemPosters.updateValue(cachedImage, forKey: cellID)
			return
		}

		network.fetchContentItem(uri: uri) { image in
			if let image = image {
				self.imageCache[cellID] = image
				self.itemPosters.updateValue(image, forKey: cellID)
				NotificationCenter.default.post(name: .imageLoaded, object: nil, userInfo: ["cellID": cellID])
			}
		}
	}
}

extension Notification.Name {
	static let imageLoaded = Notification.Name("imageLoaded")
}
