//
//  HeaderView.swift
//  musicPlayerApp
//
//  Created by Nursultan Kabulov on 15.07.2024.
//

import UIKit

struct Track {
	let imageName: String
}

class HeaderView: UICollectionReusableView {

	static var reuseIdentifier: String {
		return String(describing: self)
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
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		self.widthConstraint = imageView.widthAnchor.constraint(equalToConstant: 200)
		self.heightConstraint = imageView.heightAnchor.constraint(equalToConstant: 200)
		imageView.layer.shadowColor = UIColor.black.cgColor
		imageView.layer.shadowOpacity = 0.7
		imageView.layer.shadowOffset = CGSize.zero
		imageView.layer.shadowRadius = 10
		imageView.layer.masksToBounds = false
		return imageView
	}()

	private lazy var albumTitle: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = .systemGray
		label.numberOfLines = 0
		label.textAlignment = .center
		label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
		return label
	}()

	var widthConstraint: NSLayoutConstraint?
	var heightConstraint: NSLayoutConstraint?

	var isFloating = false

//	var track: Track? {
//		didSet {
//			guard let track = track else { return }
//			let image = UIImage(named: track.imageName) ?? UIImage(named: "Spotify_Primary_Logo_RGB_Green")!
//
//			imageView.image = image
//		}
//	}

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

			widthConstraint!,
			heightConstraint!,

			imageView.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 10),
			imageView.centerXAnchor.constraint(equalTo: stackView.centerXAnchor),

			albumTitle.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
			albumTitle.centerXAnchor.constraint(equalTo: centerXAnchor),
			albumTitle.widthAnchor.constraint(equalToConstant: 350)
		])
	}

//	override var intrinsicContentSize: CGSize {
//		return CGSize(width: 300, height: 400)
//	}

}

extension HeaderView {
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let y = scrollView.contentOffset.y
		
		guard
			let widthConstraint = widthConstraint,
			let heightConstraint = heightConstraint,
			y > 0 else { return }

		// Scroll
		let normalizedScroll = y / 2

		widthConstraint.constant = 200 - normalizedScroll
		heightConstraint.constant = 200 - normalizedScroll

		if isFloating {
			isHidden = y > 200
			albumTitle.isHidden = y > 30
		}

		// Alpha
		let normalizedAlpha = y / 200
		alpha = 1.0 - normalizedAlpha
	}
}
