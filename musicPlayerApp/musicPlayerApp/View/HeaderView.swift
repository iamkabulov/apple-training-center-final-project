//
//  HeaderView.swift
//  musicPlayerApp
//
//  Created by Nursultan Kabulov on 15.07.2024.
//

import UIKit

class HeaderView: UICollectionReusableView {

	static var reuseIdentifier: String {
		return String(describing: self)
	}

	private enum Spacing {
		enum Size {
			static let heightImage: CGFloat = 200
			static let widthImage: CGFloat = 200
			static let titleWidth: CGFloat = 350
		}
		static let small: CGFloat = 2
		static let medium: CGFloat = 10
		static let large: CGFloat = 20
	}

	private lazy var stackView: UIStackView = {
		let stackView = UIStackView()
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.addSubview(imageView)
		stackView.addSubview(albumTitle)
		stackView.axis = .vertical
		stackView.spacing = .zero
		return stackView
	}()

	private lazy var imageView: UIImageView = {
		return ImageViewBuilder()
			.setShadow(shadowColor: UIColor.black.cgColor,
					   shadowOpacity: 0.7,
					   shadowOffset: CGSize.zero,
					   shadowRadius: 10,
					   masksToBounds: false)
			.build()
	}()

	private lazy var albumTitle: UILabel = {
		return LabelBuilder()
			.setFont(UIFont.systemFont(ofSize: 18, weight: .bold))
			.setNumberOfLines(0)
			.setTextAlignment(.center)
			.setTextColor(.systemGray)
			.build()
	}()

	private lazy var widthConstraint = self.imageView.widthAnchor.constraint(equalToConstant: Spacing.Size.widthImage)
	private lazy var heightConstraint = self.imageView.heightAnchor.constraint(equalToConstant: Spacing.Size.heightImage)
	var isFloating = false

	override init(frame: CGRect) {
		super.init(frame: frame)
		layout()
	}

	required init?(coder: NSCoder) {
		fatalError()
	}

	func set(data: SPTAppRemoteContentItem) {
		self.albumTitle.text = data.subtitle == "" ? data.title : data.subtitle
	}

	func set(artist: SPTAppRemoteArtist) {
		self.albumTitle.text = artist.name
	}

	func set(image: UIImage) {
		self.imageView.image = image
	}

}

extension HeaderView {
	func layout() {
		addSubview(stackView)

		NSLayoutConstraint.activate([
			stackView.topAnchor.constraint(equalTo: topAnchor),
			stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
			stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
			stackView.bottomAnchor.constraint(equalTo: bottomAnchor),

			widthConstraint,
			heightConstraint,

			imageView.topAnchor.constraint(equalTo: stackView.topAnchor, constant: Spacing.medium),
			imageView.centerXAnchor.constraint(equalTo: stackView.centerXAnchor),

			albumTitle.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Spacing.medium),
			albumTitle.centerXAnchor.constraint(equalTo: centerXAnchor),
			albumTitle.widthAnchor.constraint(equalToConstant: Spacing.Size.titleWidth)
		])
	}

}

extension HeaderView {
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let y = scrollView.contentOffset.y
		guard y > 0 else { return }

		let normalizedScroll = y / 2

		widthConstraint.constant = 200 - normalizedScroll
		heightConstraint.constant = 200 - normalizedScroll

		if isFloating {
			isHidden = y > 200
			albumTitle.isHidden = y > 30
		}

		let normalizedAlpha = y / 200
		alpha = 1.0 - normalizedAlpha
	}
}
