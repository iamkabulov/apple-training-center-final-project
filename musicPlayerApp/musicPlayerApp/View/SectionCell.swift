//
//  SectionCell.swift
//  musicPlayerApp
//
//  Created by Nursultan Kabulov on 10.07.2024.
//

import UIKit


final class SectionCell: UITableViewCell {

	//MARK: - Properties
	static var identifier: String {
		return String(describing: self)
	}
	var viewModel: MainViewModel?
	private var images: [UIImage]?
	private var dataSource: SPTAppRemoteContentItem?

	static let rowHeight: CGFloat = 100
	private var id: Int?
	private var path: String?

	private enum Spacing {
		enum Size {
			static let height: CGFloat = 100
			static let width: CGFloat = 100
		}
		static let small: CGFloat = 1
		static let medium: CGFloat = 8
		static let large: CGFloat = 16
	}
	
	private lazy var titleLabel: UILabel = {
		let trackLabel = UILabel()
		trackLabel.translatesAutoresizingMaskIntoConstraints = false
		trackLabel.font = UIFont.preferredFont(forTextStyle: .body)
		trackLabel.textAlignment = .left
		return trackLabel
	}()

	private lazy var recommendationCollectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .horizontal
		let view = UICollectionView(
			frame: .zero,
			collectionViewLayout: layout
		)
		view.showsHorizontalScrollIndicator = false
		view.dataSource = self
		view.delegate = self
		view.register(RecommendationCell.self, forCellWithReuseIdentifier: RecommendationCell.identifier)
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private lazy var spinner: UIActivityIndicatorView = {
		let spinner = UIActivityIndicatorView(style: .medium)
		spinner.translatesAutoresizingMaskIntoConstraints = false
		return spinner
	}()

	//MARK: - ViewLifeCycle
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupLayout()
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		contentView.layoutIfNeeded()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	//MARK: - Methods
	func setData(_ vm: MainViewModel, data: SPTAppRemoteContentItem) {
		self.dataSource = data
		self.viewModel = vm
		DispatchQueue.main.async {
			self.titleLabel.text = self.dataSource?.title
			
		}
		self.recommendationCollectionView.reloadData()
	}
}

//MARK: - SectionCell
private extension SectionCell {
	func setupLayout() {
		contentView.addSubview(titleLabel)
		contentView.addSubview(recommendationCollectionView)
		NSLayoutConstraint.activate([
			titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
			titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Spacing.large),
			recommendationCollectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Spacing.medium),
			recommendationCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Spacing.large),
			recommendationCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			recommendationCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
		])
	}
}

//MARK: - UICollectionViewDataSource & UICollectionViewDelegate
extension SectionCell: UICollectionViewDataSource, UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let data = self.dataSource?.children else { return 0 }
		return data.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let data = self.dataSource?.children, let cell = self.recommendationCollectionView.dequeueReusableCell(
																				withReuseIdentifier: RecommendationCell.identifier,
																				for: indexPath) as? RecommendationCell
		else {
			return UICollectionViewCell()
		}
		if data.count > indexPath.row {
			cell.setData(vm: self.viewModel, data[indexPath.row])
			cell.bindViewModel()
		}
		return cell
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: 100, height: 100)
	}
}
