//
//  RecommendationCell.swift
//  musicPlayerApp
//
//  Created by Nursultan Kabulov on 10.07.2024.
//

import UIKit

final class RecommendationCell: UICollectionViewCell {
	//MARK: - Properties
	static var identifier: String {
		return String(describing: self)
	}

	//MARK: - StackViews

	private lazy var hStackView: UIStackView = {
		let stack = UIStackView()
		stack.addSubview(artistImage)
		stack.addSubview(artistName)
		stack.translatesAutoresizingMaskIntoConstraints = false
		stack.backgroundColor = .blue
		stack.axis = .horizontal
		stack.spacing = .zero
		return stack
	}()

	//MARK: - Labels
	private lazy var artistName: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
		label.textAlignment = .center
		label.text = "Tom Hardy"
		return label
	}()

	//MARK: - Image and Spinner
	private lazy var spinner: UIActivityIndicatorView = {
		let spinner = UIActivityIndicatorView(style: .medium)
		spinner.translatesAutoresizingMaskIntoConstraints = false
		return spinner
	}()

	private lazy var artistImage: UIImageView = {
		let image = UIImageView()
		image.translatesAutoresizingMaskIntoConstraints = false
		image.image = UIImage(named: "whiteBackground")
		image.contentMode = .scaleAspectFill
		image.heightAnchor.constraint(equalToConstant: 60).isActive = true
		image.widthAnchor.constraint(equalToConstant: 60).isActive = true
		image.layer.cornerRadius = 30
		image.clipsToBounds = true
		return image
	}()

//MARK: - LifeCycle
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupView()
		contentView.layer.masksToBounds = true
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		contentView.layoutIfNeeded()
	}
}

//MARK: - Methods
extension RecommendationCell {
	func setupView() {
		contentView.addSubview(hStackView)
		NSLayoutConstraint.activate([
			hStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
			hStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			hStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			hStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

			artistImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
		])
	}

	func setData(_ data: SPTAppRemoteContentItem?) {
		self.artistName.text = data?.title
	}

	func loadImage(from url: String) {

	}

	func setImage(img: UIImage?) {
		guard let img = img else {
			hStackView.addSubview(spinner)
			spinner.startAnimating()
			spinner.isHidden = false
			contentView.layoutIfNeeded()
			return
		}
		self.spinner.stopAnimating()
		self.spinner.isHidden = true
		self.artistImage.image = img
		self.contentView.layoutIfNeeded()
	}
}
