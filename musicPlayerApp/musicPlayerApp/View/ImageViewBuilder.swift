//
//  ImageViewBuilder.swift
//  musicPlayerApp
//
//  Created by Nursultan Kabulov on 25.07.2024.
//

import Foundation

class ImageViewBuilder {
	private let imageView: UIImageView

	init() {
		self.imageView = UIImageView()
		self.imageView.translatesAutoresizingMaskIntoConstraints = false
	}

	func setContentMode(_ contentMode: UIView.ContentMode) -> ImageViewBuilder {
		self.imageView.contentMode = contentMode
		return self
	}

	func setImage(named name: String) -> ImageViewBuilder {
		self.imageView.image = UIImage(named: name)
		return self
	}

	func setImage(_ image: UIImage?) -> ImageViewBuilder {
		self.imageView.image = image
		return self
	}

	func setClipsToBounds(_ clipsToBounds: Bool) -> ImageViewBuilder {
		self.imageView.clipsToBounds = clipsToBounds
		return self
	}

	func setTranslatesAutoresizingMaskIntoConstraints(_ flag: Bool) -> ImageViewBuilder {
		self.imageView.translatesAutoresizingMaskIntoConstraints = flag
		return self
	}

	func setCornerRadius(_ cornerRadius: CGFloat) -> ImageViewBuilder {
		self.imageView.layer.cornerRadius = cornerRadius
		return self
	}

	func build() -> UIImageView {
		return self.imageView
	}
}
