//
//  SceneDelegate.swift
//  musicPlayerApp
//
//  Created by Nursultan Kabulov on 08.07.2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	var window: UIWindow?
	lazy var rootViewController = LogInViewController()


	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let windowScene = (scene as? UIWindowScene) else { return }
		window = UIWindow(frame: UIScreen.main.bounds)
		window!.makeKeyAndVisible()
		window!.windowScene = windowScene
		window!.rootViewController = rootViewController
	}

	// For spotify authorization and authentication flow
	func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
		guard let url = URLContexts.first?.url else { return }
		let parameters = rootViewController.viewModel?.network.appRemote.authorizationParameters(from: url)
		if let code = parameters?["code"] {
			rootViewController.viewModel?.network.responseCode = code
		} else if let access_token = parameters?[SPTAppRemoteAccessTokenKey] {
			rootViewController.viewModel?.network.accessToken = access_token
		} else if let error_description = parameters?[SPTAppRemoteErrorDescriptionKey] {
			print("No access token error =", error_description)
		}
	}

	func sceneDidBecomeActive(_ scene: UIScene) {
//		if let accessToken = rootViewController.viewModel?.network.appRemote.connectionParameters.accessToken {
//			rootViewController.viewModel?.network.appRemote.connectionParameters.accessToken = accessToken
//			rootViewController.viewModel?.network.appRemote.connect()
//		} else if let accessToken = rootViewController.viewModel?.network.accessToken {
//			rootViewController.viewModel?.network.appRemote.connectionParameters.accessToken = accessToken
//			rootViewController.viewModel?.network.appRemote.connect()
//		}
	}

	func sceneWillResignActive(_ scene: UIScene) {
		guard let viewModel = rootViewController.viewModel else { return }
		if viewModel.network.appRemote.isConnected {
//			rootViewController.viewModel?.network.appRemote.disconnect()
		}
	}

	func switchRoot(vc: UIViewController) {

		window?.makeKeyAndVisible()
		window?.rootViewController = vc
	}
}
