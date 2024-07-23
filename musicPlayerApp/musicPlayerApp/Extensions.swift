//
//  Extensions.swift
//  musicPlayerApp
//
//  Created by Nursultan Kabulov on 18.07.2024.
//

import Foundation

extension Notification.Name {
	static let imageLoaded = Notification.Name("imageLoaded")
	static let miniPlayerTapped = Notification.Name("miniPlayerTapped")
}

extension UIViewController {
	func hideKeyboardWhenTappedAround() {
		let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
		tap.cancelsTouchesInView = false
		view.addGestureRecognizer(tap)
	}

	@objc func dismissKeyboard() {
		view.endEditing(true)
	}
}
