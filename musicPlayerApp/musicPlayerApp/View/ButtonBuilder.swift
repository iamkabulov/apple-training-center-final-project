//
//  ButtonBuilder.swift
//  musicPlayerApp
//
//  Created by Nursultan Kabulov on 25.07.2024.
//

import UIKit

class ButtonBuilder {
	private let button: UIButton

	init() {
		self.button = UIButton()
		self.button.translatesAutoresizingMaskIntoConstraints = false
	}

	func setImage(_ image: UIImage?, for state: UIControl.State) -> ButtonBuilder {
		self.button.setImage(image, for: state)
		self.button.imageView?.contentMode = .scaleAspectFit
		return self
	}

	func setTitle(_ title: String?, for state: UIControl.State) -> ButtonBuilder {
		self.button.setTitle(title, for: state)
		return self
	}

	func setTitleColor(_ color: UIColor, for state: UIControl.State) -> ButtonBuilder {
		self.button.setTitleColor(color, for: state)
		return self
	}

	func setBackgroundColor(_ color: UIColor) -> ButtonBuilder {
		self.button.backgroundColor = color
		return self
	}

	func setTintColor(_ color: UIColor) -> ButtonBuilder {
		self.button.tintColor = color
		return self
	}

	func setTranslatesAutoresizingMaskIntoConstraints(_ flag: Bool) -> ButtonBuilder {
		self.button.translatesAutoresizingMaskIntoConstraints = flag
		return self
	}

	func addTarget(_ target: Any?, action: Selector, for event: UIControl.Event) -> ButtonBuilder {
		self.button.addTarget(target, action: action, for: event)
		return self
	}

	func setConfiguration(_ cfg: UIButton.Configuration) -> ButtonBuilder {
		self.button.configuration = cfg
		return self
	}

	func setFont(_ font: UIFont) -> ButtonBuilder {
		self.button.titleLabel?.font = font
		return self
	}

	func setBorder(color: CGColor, width: CGFloat, cornerRadius: CGFloat) -> ButtonBuilder {
		self.button.layer.borderColor = color
		self.button.layer.borderWidth = width
		self.button.layer.cornerRadius = cornerRadius
		return self
	}

	func build() -> UIButton {
		return self.button
	}
}
