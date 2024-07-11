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

	var accessToken = UserDefaults.standard.string(forKey: accessTokenKey) {
		didSet {
			let defaults = UserDefaults.standard
			defaults.set(accessToken, forKey: accessTokenKey)
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

	func fetchPlayerState(completionHandler: @escaping ((SPTAppRemotePlayerState?) -> Void)) {
		appRemote.playerAPI?.getPlayerState { (playerState, error) in
			if let error = error {
				print("Error getting player state:" + error.localizedDescription)
			} else if let playerState = playerState as? SPTAppRemotePlayerState {
//				self?.update(playerState: playerState)
				completionHandler(playerState)
				///VIEWMODEL BIND
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
