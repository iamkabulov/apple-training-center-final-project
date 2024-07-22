//
//  Authentication.swift
//  musicPlayerApp
//
//  Created by Nursultan Kabulov on 22.07.2024.
//

import Foundation


extension NetworkManager
{
	func createRequest(url: URL, httpMethod: String, headers: [String: String], body: Data?) -> URLRequest {
		var request = URLRequest(url: url)
		request.httpMethod = httpMethod
		headers.forEach { key, value in
			request.setValue(value, forHTTPHeaderField: key)
		}
		request.httpBody = body
		return request
	}

	func createAuthorizationHeader(clientId: String, clientSecret: String) -> String {
		let authStr = "\(clientId):\(clientSecret)"
		let authData = authStr.data(using: .utf8)
		let base64AuthStr = authData?.base64EncodedString() ?? ""
		return "Basic \(base64AuthStr)"
	}

	func fetchAccessToken(completion: @escaping ([String: Any]?, Error?) -> Void) {
		let headers = [
			"Authorization": createAuthorizationHeader(clientId: spotifyClientId, 
													   clientSecret: spotifyClientSecretKey),
			"Content-Type": "application/x-www-form-urlencoded"
		]

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

		let request = createRequest(url: tokenURL,
									httpMethod: "POST",
									headers: headers,
									body: requestBodyComponents.query?.data(using: .utf8))

		let task = URLSession.shared.dataTask(with: request) { data, response, error in
			guard let data = data,
				  let response = response as? HTTPURLResponse,
				  (200 ..< 300) ~= response.statusCode,
				  error == nil else {
				print("Error fetching token \(error?.localizedDescription ?? "")")
				return completion(nil, error)
			}
			let responseObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
			print("Access Token Dictionary=", responseObject ?? "")
			completion(responseObject, nil)
		}
		task.resume()
	}

	func fetchAccessTokenClient(completion: @escaping (String?) -> Void) {
		let headers = [
			"Authorization": createAuthorizationHeader(clientId: spotifyClientId, 
													   clientSecret: spotifyClientSecretKey),
			"Content-Type": "application/x-www-form-urlencoded"
		]

		let bodyStr = "grant_type=client_credentials"
		let request = createRequest(url: tokenURL,
									httpMethod: "POST",
									headers: headers,
									body: bodyStr.data(using: .utf8))

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
}
