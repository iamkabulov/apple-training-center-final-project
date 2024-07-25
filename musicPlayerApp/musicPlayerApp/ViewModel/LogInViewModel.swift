//
//  LogInViewModel.swift
//  musicPlayerApp
//
//  Created by Nursultan Kabulov on 09.07.2024.
//

import UIKit

final class LogInViewModel {
	
	var network = NetworkManager.shared
	
	init(_ view: SPTAppRemoteDelegate) {
		self.network.appRemote.delegate = view
	}

	func getToken(completionHandler: @escaping (SPTAppRemote) -> Void) {
		guard let sessionManager = network.sessionManager else { return }
		sessionManager.initiateSession(with: scopes, options: .clientOnly, campaign: "")
		if network.appRemote.isConnected {
			let appRemote = network.appRemote
			completionHandler(appRemote)
		} else {
			if let accessToken = network.appRemote.connectionParameters.accessToken {
				network.appRemote.connectionParameters.accessToken = accessToken
				network.appRemote.connect()
			} else if let accessToken = network.accessToken {
				network.appRemote.connectionParameters.accessToken = accessToken
				network.appRemote.connect()
				completionHandler(network.appRemote)
			}
		}
	}
}
