//
//  MusicBarController.swift
//  musicPlayerApp
//
//  Created by Nursultan Kabulov on 12.07.2024.
//

import UIKit

final class MusicBarController: UITabBarController {

	override func viewDidLoad() {
		super.viewDidLoad()
		setupViews()
		configure()
	}

	func setupViews() {
		let mainViewController = MainViewController()
		let profileController = UIViewController()

		let homeNav = UINavigationController(rootViewController: mainViewController)
		mainViewController.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), selectedImage: nil)
		profileController.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.crop.circle"), selectedImage: nil)

		let tabBarList = [homeNav, profileController]
		self.viewControllers = tabBarList
	}


	func configure() {
		self.tabBar.tintColor = .label
	}
}
