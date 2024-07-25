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

	private enum Spacing {
		enum Size {
			static let height: CGFloat = 130
			static let width: CGFloat = 130
		}
		static let small: CGFloat = 1
		static let medium: CGFloat = 8
		static let large: CGFloat = 16
	}

	weak var viewModel: MainViewModel?
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
		return LabelBuilder()
			.setFont(UIFont.systemFont(ofSize: 12, weight: .regular))
			.setTextAlignment(.left)
			.setTextColor(.lightGray)
			.setNumberOfLines(2)
			.build()
	}()

	//MARK: - Image
	private lazy var artistImage: UIImageView = {
		return ImageViewBuilder()
			.setImage(named: "whiteBackground")
			.setContentMode(.scaleAspectFit)
			.setClipsToBounds(true)
			.build()
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
		print("RECCOMMENDATION DEINIT")
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
		artistImage.image = UIImage(named: "whiteBackground")
		viewModel = nil
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

	func unBindViewModel() {
		self.viewModel?.itemPosters.unbind()
		self.viewModel = nil
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
			artistImage.heightAnchor.constraint(equalToConstant: Spacing.Size.height),
			artistImage.widthAnchor.constraint(equalToConstant: Spacing.Size.width),

			artistName.topAnchor.constraint(equalTo: artistImage.bottomAnchor, constant: Spacing.medium),
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
		self.viewModel?.getPosters(forCellWithID: data.identifier, for: data)
	}
}
