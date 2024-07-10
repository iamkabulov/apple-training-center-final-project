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
}
