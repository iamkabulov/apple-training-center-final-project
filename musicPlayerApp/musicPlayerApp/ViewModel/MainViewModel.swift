//
//  MainViewModel.swift
//  musicPlayerApp
//
//  Created by Nursultan Kabulov on 10.07.2024.
//

import Foundation

final class MainViewModel {

	var network = NetworkManager.shared
	var contentItems: Observable<[SPTAppRemoteContentItem]> = Observable(nil)
	var itemPosters: ObservableDictionary<String, UIImage> = ObservableDictionary()

	init(_ view: SPTAppRemoteDelegate) {
		self.network.appRemote.delegate = view
	}

	func getContentItems() {
		network.fetchContentItems { contentItems in
			self.contentItems.value = contentItems
		}
	}

	func getPosters(forCellWithID cellID: String, for uri: SPTAppRemoteContentItem?) {
		guard let id = uri?.uri else { return }
		if let cachedImage = ImageCache.shared.object(forKey: id as NSString) {
			return
		}
		network.fetchContentItem(uri: uri) { image in
			if let image = image {
				self.itemPosters.updateValue(image, forKey: cellID)
				NotificationCenter.default.post(name: .imageLoaded, object: nil, userInfo: ["cellID": cellID])
			}
		}
	}
}
