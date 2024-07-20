//
//  NetworkManager.swift
//  musicPlayerApp
//
//  Created by Nursultan Kabulov on 09.07.2024.
//

import UIKit


final class NetworkManager: NSObject {
	
	
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
		// Set the playURI to a non-nil value so that Spotify plays music after authenticating
		// otherwise another app switch will be required
		configuration.playURI = ""
		// Set these url's to your backend which contains the secret to exchange for an access token
		// You can use the provided ruby script spotify_token_swap.rb for testing purposes
		configuration.tokenSwapURL = URL(string: "http://localhost:1234/swap")
		configuration.tokenRefreshURL = URL(string: "http://localhost:1234/refresh")
		return configuration
	}()

	lazy var sessionManager: SPTSessionManager? = {
		let manager = SPTSessionManager(configuration: configuration, delegate: self)
		return manager
	}()

	func fetchAccessToken(completion: @escaping ([String: Any]?, Error?) -> Void) {
		let url = URL(string: "https://accounts.spotify.com/api/token")!
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		let spotifyAuthKey = "Basic \((spotifyClientId + ":" + spotifyClientSecretKey).data(using: .utf8)!.base64EncodedString())"
		request.allHTTPHeaderFields = ["Authorization": spotifyAuthKey,
									   "Content-Type": "application/x-www-form-urlencoded"]

		var requestBodyComponents = URLComponents()
		let scopeAsString = stringScopes.joined(separator: " ")

		requestBodyComponents.queryItems = [
			URLQueryItem(name: "client_id", value: spotifyClientId),
			URLQueryItem(name: "grant_type", value: "authorization_code"),
			URLQueryItem(name: "code", value: responseCode!),
			URLQueryItem(name: "redirect_uri", value: redirectUri.absoluteString),
			URLQueryItem(name: "code_verifier", value: ""), // not currently used
			URLQueryItem(name: "scope", value: scopeAsString),
		]

		request.httpBody = requestBodyComponents.query?.data(using: .utf8)

		let task = URLSession.shared.dataTask(with: request) { data, response, error in
			guard let data = data,                              // is there data
				  let response = response as? HTTPURLResponse,  // is there HTTP response
				  (200 ..< 300) ~= response.statusCode,         // is statusCode 2XX
				  error == nil else {                           // was there no error, otherwise ...
					  print("Error fetching token \(error?.localizedDescription ?? "")")
					  return completion(nil, error)
				  }
			let responseObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
			print("Access Token Dictionary=", responseObject ?? "")
			completion(responseObject, nil)
		}
		task.resume()
	}

	func fetchArtwork(for track: SPTAppRemoteImageRepresentable, completionHandler: @escaping ((UIImage?) -> Void)) {

		appRemote.imageAPI?.fetchImage(forItem: track, with: CGSize.zero, callback: { (image, error) in
			if let error = error {
				print("Error fetching track image: " + error.localizedDescription)
			} else if let image = image as? UIImage {
				completionHandler(image)
			}
		})
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
		appRemote.imageAPI?.fetchImage(forItem: uri, with: CGSize.zero) { image, error in
			if let error = error {
				print("Error fetching Item image: " + error.localizedDescription)
			} else if let image = image as? UIImage {
				print("________________ ПОЛУЧИЛ КАРТИНКУ")
				completionHandler(image)
			}
		}
	}

	func fetchContentItemChildren(contentItem: SPTAppRemoteContentItem?, completionHandler: @escaping (([SPTAppRemoteContentItem]?) -> Void)) {
		guard let contentItem = contentItem else { return }
		appRemote.contentAPI?.fetchChildren(of: contentItem) { items, error in
			if let error = error {
				print("Error fetching Item image: " + error.localizedDescription)
			} else if let items = items as? [SPTAppRemoteContentItem] {
				print("________________ ПОЛУЧИЛ CHILDRENs \(items)")
				completionHandler(items)
			}
		}
	}

	func fetchAccessTokenClient(completion: @escaping (String?) -> Void) {
		let tokenURL = "https://accounts.spotify.com/api/token"
		var request = URLRequest(url: URL(string: tokenURL)!)
		request.httpMethod = "POST"
		request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

		let authStr = "\(spotifyClientId):\(spotifyClientSecretKey)"
		let authData = authStr.data(using: .utf8)
		let base64AuthStr = authData?.base64EncodedString() ?? ""
		request.setValue("Basic \(base64AuthStr)", forHTTPHeaderField: "Authorization")

		let bodyStr = "grant_type=client_credentials"
		request.httpBody = bodyStr.data(using: .utf8)

		let task = URLSession.shared.dataTask(with: request) { data, response, error in
			guard let data = data, error == nil else {
				print("Error fetching access token: \(error?.localizedDescription ?? "Unknown error")")
				completion(nil)
				return
			}

			do {
				if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
				   let accessToken = json["access_token"] as? String {
					completion(accessToken)
				} else {
					completion(nil)
				}
			} catch {
				print("Error parsing JSON: \(error.localizedDescription)")
				completion(nil)
			}
		}

		task.resume()
	}

	func getTokenForSearch() {
		fetchAccessTokenClient { [weak self] accessToken in
			guard let self = self, let token = accessToken else {
				print("Failed to fetch access token")
				return
			}
			clientCredentials = token
		}
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
		
		print(request)
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
//										, callback: { response, error in
//			if let error = error {
//				print("Error SHUFFLE player state:" + error.localizedDescription)
//			} else if let playerState = response as? SPTAppRemotePlayerState {
//				completionHandler(playerState)
//			}
//		})
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
		} else {
//			presentAlertController(title: "Authorization Failed", message: error.localizedDescription, buttonTitle: "Bummer")
			///VIEW BIND
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
