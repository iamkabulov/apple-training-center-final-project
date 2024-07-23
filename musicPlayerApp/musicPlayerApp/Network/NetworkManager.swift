//
//  NetworkManager.swift
//  musicPlayerApp
//
//  Created by Nursultan Kabulov on 09.07.2024.
//

import UIKit


final class NetworkManager: NSObject
{
	static let shared = NetworkManager()

	lazy var appRemote: SPTAppRemote = {
		let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
		appRemote.connectionParameters.accessToken = self.accessToken
		return appRemote
	}()

	lazy private var urlComponent: URLComponents = {
			var component = URLComponents()
			component.scheme = "https"
			component.host = "api.spotify.com"
			return component
	}()

	var accessToken = UserDefaults.standard.string(forKey: accessTokenKey) {
		didSet {
			let defaults = UserDefaults.standard
			defaults.set(accessToken, forKey: accessTokenKey)
		}
	}

	var clientCredentials = UserDefaults.standard.string(forKey: clientCredentialKey) {
		didSet {
			let defaults = UserDefaults.standard
			defaults.set(clientCredentials, forKey: clientCredentialKey)
		}
	}

	var responseCode: String? {
		didSet {
			fetchAccessToken { (dictionary, error) in
				if let error = error {
					print("Fetching token request error \(error)")
					return
				}
				let accessToken = dictionary!["access_token"] as! String
				DispatchQueue.main.async {
					self.accessToken = accessToken
					self.appRemote.connectionParameters.accessToken = accessToken
					self.appRemote.connect()
				}
			}
		}
	}

	lazy var configuration: SPTConfiguration = {
		let configuration = SPTConfiguration(clientID: spotifyClientId, redirectURL: redirectUri)
		configuration.playURI = ""
		configuration.tokenSwapURL = URL(string: "http://localhost:1234/swap")
		configuration.tokenRefreshURL = URL(string: "http://localhost:1234/refresh")
		return configuration
	}()

	lazy var sessionManager: SPTSessionManager? = {
		let manager = SPTSessionManager(configuration: configuration, delegate: self)
		return manager
	}()

	func fetchArtwork(for track: SPTAppRemoteImageRepresentable, completionHandler: @escaping ((UIImage?) -> Void)) {
		let cachedKey = track.imageIdentifier
		if let cachedImage = ImageCache.shared.object(forKey: cachedKey as NSString) {
			completionHandler(cachedImage)
		} else {
			appRemote.imageAPI?.fetchImage(forItem: track, with: CGSize.zero, callback: { (image, error) in
				if let error = error {
					print("Error fetching track image: " + error.localizedDescription)
				} else if let image = image as? UIImage {
					ImageCache.shared.setObject(image, forKey: cachedKey as NSString)
					completionHandler(image)
				}
			})
		}
	}

	func fetchContentItems(completionHandler: @escaping (([SPTAppRemoteContentItem]?) -> Void)) {
		appRemote.contentAPI?.fetchRecommendedContentItems(forType: SPTAppRemoteContentTypeNavigation, flattenContainers: false, callback: { (result, error) in
			if let error = error {
				print("Error fetching content: " + error.localizedDescription)
			} else if let result = result {
				completionHandler(result as? [any SPTAppRemoteContentItem])
			}
		})
	}

	func fetchContentItem(uri: SPTAppRemoteContentItem?, completionHandler: @escaping ((UIImage?) -> Void)) {
		guard let uri = uri else { return }
		if let cachedImage = ImageCache.shared.object(forKey: uri.uri as NSString) {
			completionHandler(cachedImage)
		} else {
			appRemote.imageAPI?.fetchImage(forItem: uri, with: CGSize.zero) { image, error in
				if let error = error {
					print("Error fetching Item image: " + error.localizedDescription)
				} else if let image = image as? UIImage {
					ImageCache.shared.setObject(image, forKey: uri.uri as NSString)
					completionHandler(image)
				}
			}
		}
	}

	func fetchContentItemChildren(contentItem: SPTAppRemoteContentItem?, completionHandler: @escaping (([SPTAppRemoteContentItem]?) -> Void)) {
		guard let contentItem = contentItem else { return }
		appRemote.contentAPI?.fetchChildren(of: contentItem) { items, error in
			if let error = error {
				print("Error fetching Item image: " + error.localizedDescription)
			} else if let items = items as? [SPTAppRemoteContentItem] {
				completionHandler(items)
			}
		}
	}

	func getFavouriteLibrary(completionHandler: @escaping ((SPTAppRemoteContentItem) -> Void)) {
		appRemote.contentAPI?.fetchContentItem(forURI: "spotify:user:31pnwwukd7usbaxhwzmcqjrrczxe:collection", callback: { res, error in
			if let error = error {
				print("Error fetching Item image: " + error.localizedDescription)
			} else if let item = res as? SPTAppRemoteContentItem {
				completionHandler(item)
			}
		})
	}

	func search(byName: String, completionHandler: @escaping ((TrackEntity) -> Void)) {
		self.urlComponent.path = "/v1/search"
		self.urlComponent.queryItems = [URLQueryItem(name: "q", value: byName),
										URLQueryItem(name: "type", value: "track"),
										URLQueryItem(name: "market", value: "KZ"),
										URLQueryItem(name: "limit", value: "10"),
										URLQueryItem(name: "offset", value: "0")]
		guard let requestURL = self.urlComponent.url else { return }
		guard let token = self.clientCredentials else { return }
		let headers = [
			"Authorization": "Bearer \(token)"
		]
		var request = URLRequest(url: requestURL)
		print(request)
		request.allHTTPHeaderFields = headers

		let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
			guard let data = data, error == nil else { return }
			do {
				let str = String(data: data, encoding: .utf8)
				print("____________________________________")
				print(str ?? "")
				let response = try JSONDecoder().decode(TrackEntity.self, from: data)
//				print(response)
				completionHandler(response)
				return
			} catch {
				return print(error)
			}
		}
		task.resume()
	}

	func getArtistDetails(uri: String, completionHandler: @escaping ((ArtistEntity) -> Void)) {
		self.urlComponent.path = "/v1/artists/\(uri)"
		guard let requestURL = self.urlComponent.url else { return }
		guard let token = self.clientCredentials else { return }
		let headers = [
			"Authorization": "Bearer \(token)"
		]
		var request = URLRequest(url: requestURL)
		print(request)
		request.allHTTPHeaderFields = headers

		let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
			guard let data = data, error == nil else { return }
			do {
				let str = String(data: data, encoding: .utf8)
				print(str ?? "")
				let response = try JSONDecoder().decode(ArtistEntity.self, from: data)
				completionHandler(response)
				return
			} catch {
				return print(error)
			}
		}
		task.resume()
	}

	func fetchArtistImage(url: String, completionHandler: @escaping ((UIImage) -> Void)) {
		guard let URL = URL(string: url) else { return }
		var request = URLRequest(url: URL)

		let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
			guard let data = data, error == nil else { return }
			guard let response = UIImage(data: data) else { return }
			completionHandler(response)
			return
		}
		task.resume()
	}

	func play(item uri: SPTAppRemoteContentItem) {
		appRemote.playerAPI?.play(uri, skipToTrackIndex: 0, callback: { response, error in
			if let error = error {
				print("Error getting player state:" + error.localizedDescription)
			} else if let response = response  {
				print(response)
			}
		})
	}

	func play(trackUri uri: String) {
		appRemote.playerAPI?.play(uri, asRadio: false, callback: { response, error in
			if let error = error {
				print("Error getting player state:" + error.localizedDescription)
			} else if let response = response  {
				print(response)
			}
		})
	}

	func fetchPlayerState(completionHandler: @escaping ((SPTAppRemotePlayerState?) -> Void)) {
		appRemote.playerAPI?.getPlayerState { (playerState, error) in
			if let error = error {
				print("Error getting player state:" + error.localizedDescription)
			} else if let playerState = playerState as? SPTAppRemotePlayerState {
				completionHandler(playerState)
			}
		}
	}

	func play() {
		appRemote.playerAPI?.resume(nil)
	}

	func pause() {
		appRemote.playerAPI?.pause(nil)
	}

	func next(completionHandler: @escaping (SPTAppRemotePlayerState?) -> Void) {
		appRemote.playerAPI?.skip(toNext: { response, error in
			if let error = error {
				print("Error getting player state:" + error.localizedDescription)
			} else if let playerState = response as? SPTAppRemotePlayerState {
				completionHandler(playerState)
			}
		})
	}

	func previous(completionHandler: @escaping (SPTAppRemotePlayerState?) -> Void) {
		appRemote.playerAPI?.skip(toPrevious: { response, error in
			if let error = error {
				print("Error getting player state:" + error.localizedDescription)
			} else if let playerState = response as? SPTAppRemotePlayerState {
				completionHandler(playerState)
			}
		})
	}

	func shuffle(_ isShuffled: Bool, completionHandler: @escaping (SPTAppRemotePlayerState?) -> Void) {
		appRemote.playerAPI?.setShuffle(isShuffled)
	}

	func repeatMode(_ options: SPTAppRemotePlaybackOptionsRepeatMode) {
		appRemote.playerAPI?.setRepeatMode(options)
		
	}

	func seekToPosition(_ position: Int) {
		appRemote.playerAPI?.seek(toPosition: position * 1000)
	}

	func subscribeToState(completionHandler: @escaping (SPTAppRemotePlayerState)->Void) {
		appRemote.playerAPI?.subscribe { success, error in
			if let error = error {
				print("Error subscribing to player state:" + error.localizedDescription)
			} else if let success = success as? SPTAppRemotePlayerState {
				completionHandler(success)
			}
		}
	}

	func addToLibraryWith(uri: String) {
		appRemote.userAPI?.addItemToLibrary(withURI: uri) { success, error in
			if let error = error {
				print("Error subscribing to player state:" + error.localizedDescription)
			} else if let success = success as? SPTAppRemoteLibraryState {
				print(success)
			}
		}
	}

	func removeFromLibrary(uri: String) {
		appRemote.userAPI?.removeItemFromLibrary(withURI: uri) { success, error in
			if let error = error {
				print("Error subscribing to player state:" + error.localizedDescription)
			} else if let success = success as? SPTAppRemoteLibraryState {
				print(success)
			}
		}
	}

	func getTrackState(uri: String, completionHandler: @escaping (SPTAppRemoteLibraryState)->Void) {
		appRemote.userAPI?.fetchLibraryState(forURI: uri) { success, error in
			if let error = error {
				print("Error subscribing to player state:" + error.localizedDescription)
			} else if let success = success as? SPTAppRemoteLibraryState {
				completionHandler(success)
			}
		}
	}
}

extension NetworkManager: SPTSessionManagerDelegate {
	func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
		if error.localizedDescription == "The operation couldn’t be completed. (com.spotify.sdk.login error 1.)" {
			print("AUTHENTICATE with WEBAPI")
		}
	}

	func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
//		presentAlertController(title: "Session Renewed", message: session.description, buttonTitle: "Sweet")
		///VIEW BIND
	}

	func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
		appRemote.connectionParameters.accessToken = session.accessToken
		appRemote.connect()
	}
}
