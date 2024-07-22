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

	var viewModel: MainViewModel?
	var id: String?

	//MARK: - StackViews
	private lazy var hStackView: UIStackView = {
		let stack = UIStackView()
		stack.addSubview(artistImage)
		stack.addSubview(artistName)
		stack.translatesAutoresizingMaskIntoConstraints = false
		stack.axis = .vertical
		stack.spacing = .zero
		return stack
	}()

	//MARK: - Labels
	private lazy var artistName: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
		label.textAlignment = .left
		label.textColor = .lightGray
		label.numberOfLines = 2
		return label
	}()

	//MARK: - Image
	private lazy var artistImage: UIImageView = {
		let image = UIImageView()
		image.translatesAutoresizingMaskIntoConstraints = false
		image.image = nil
		image.contentMode = .scaleAspectFit
		image.heightAnchor.constraint(equalToConstant: 130).isActive = true
		image.widthAnchor.constraint(equalToConstant: 130).isActive = true
		image.clipsToBounds = true
		return image
	}()

	//MARK: - LifeCycle
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupView()
		contentView.layer.masksToBounds = true
		NotificationCenter.default.addObserver(self, selector: #selector(updateImage(notification:)), name: .imageLoaded, object: nil)
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
	}

	@objc private func updateImage(notification: Notification) {
		 guard let userInfo = notification.userInfo, let cellID = userInfo["cellID"] as? String, cellID == self.id else { return }
		 DispatchQueue.main.async {
			 if let image = self.viewModel?.itemPosters.value(forKey: cellID) {
				 self.artistImage.image = image
			 }
		 }
	 }

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		contentView.layoutIfNeeded()
		artistImage.image = nil
	}

	func bindViewModel() {
		self.viewModel?.itemPosters.bind { [weak self] dict in
			if let self = self, let id = self.id, let image = dict[id] {
				DispatchQueue.main.async {
					self.artistImage.image = image
				}
			}
		}
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

			artistImage.topAnchor.constraint(equalTo: contentView.topAnchor),
			artistImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),

			artistName.topAnchor.constraint(equalTo: artistImage.bottomAnchor, constant: 8),
			artistName.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			artistName.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
		])
	}

	func setData(vm: MainViewModel?, _ data: SPTAppRemoteContentItem?) {
		guard let data = data else { return }
		self.viewModel = vm
		self.id = data.identifier
		if data.subtitle == "" {
			self.artistName.text = data.title
		} else {
			self.artistName.text = data.subtitle
		}
		bindViewModel()
		if let cachedImage = viewModel?.itemPosters.value(forKey: data.identifier) {
			DispatchQueue.main.async {
				self.artistImage.image = cachedImage
			}
		} else {
			self.viewModel?.getPosters(forCellWithID: data.identifier, for: data)
		}
	}
}
