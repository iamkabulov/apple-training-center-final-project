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
	weak var viewModel: MainViewModel?
	weak var viewController: MainViewController?
	private var dataSource: SPTAppRemoteContentItem?

	static let rowHeight: CGFloat = 240

	private enum Spacing {
		enum Size {
			static let height: CGFloat = 100
			static let width: CGFloat = 100
		}
		static let small: CGFloat = 1
		static let medium: CGFloat = 8
		static let large: CGFloat = 16
	}
	//MARK: - StackViews
	private lazy var vStackView: UIStackView = {
		let stack = UIStackView()
		stack.addSubview(titleLabel)
		stack.addSubview(recommendationCollectionView)
		stack.translatesAutoresizingMaskIntoConstraints = false
		stack.axis = .vertical
		stack.spacing = .zero
		return stack
	}()

	private lazy var titleLabel: UILabel = {
		let trackLabel = UILabel()
		trackLabel.translatesAutoresizingMaskIntoConstraints = false
		trackLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
		trackLabel.numberOfLines = 0
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

	//MARK: - ViewLifeCycle
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupLayout()
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		viewController = nil
		viewModel = nil
		dataSource = nil
		contentView.layoutIfNeeded()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	deinit {
		print("DEINIT")
	}


	//MARK: - Methods
	func setData(viewController controller: MainViewController,
				 viewModel vm: MainViewModel,
				 data: SPTAppRemoteContentItem)
	{
		
		self.viewController = controller
		self.dataSource = data
		self.viewModel = vm
		if let textTitle = data.title {
			let components = textTitle.components(separatedBy: ": ")
			if components.count > 1 {
				guard let first = components.first, let second = components.last else { return }
				self.styleLabel(label: self.titleLabel, small: "\(first):\n", large: second)
			} else {
				self.titleLabel.text = data.title
			}
//			self.recommendationCollectionView.reloadData() ////тут подумать как сделать retainCycle
		}
		self.recommendationCollectionView.reloadData() ////тут подумать как сделать retainCycle
	}
}

//MARK: - SectionCell
private extension SectionCell {
	func setupLayout() {
		contentView.addSubview(vStackView)
		NSLayoutConstraint.activate([
			vStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
			vStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Spacing.large),
			vStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			vStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: Spacing.large),

			titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
			titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Spacing.large),
			titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Spacing.large),
//			titleLabel.heightAnchor.constraint(equalToConstant: 50),

			recommendationCollectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Spacing.small),
			recommendationCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Spacing.large),
			recommendationCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			recommendationCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
		])
	}

	func styleLabel(label: UILabel, small: String, large: String) {
		let attributedText = NSMutableAttributedString()

		let smallText = NSAttributedString(
			string: "\(small)",
			attributes: [
				.font: UIFont.systemFont(ofSize: 12, weight: .bold),
				.foregroundColor: UIColor.systemGray2
			]
		)
		attributedText.append(smallText)

		let largeText = NSAttributedString(
			string: "\(large)",
			attributes: [
				.font: UIFont.systemFont(ofSize: 24, weight: .bold)
			]
		)
		attributedText.append(largeText)

		label.attributedText = attributedText
	}
}

//MARK: - UICollectionViewDataSource & UICollectionViewDelegate
extension SectionCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let data = self.dataSource?.children else { return 0 }
		return data.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let data = self.dataSource?.children, let cell = self.recommendationCollectionView.dequeueReusableCell(withReuseIdentifier: RecommendationCell.identifier,
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
		return CGSize(width: 130, height: 170)
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let data = self.dataSource?.children else { return }
		let vc = ListViewController(item: data[indexPath.row])
		let cell = collectionView.cellForItem(at: indexPath) as? RecommendationCell
		self.viewController?.navigationController?.pushViewController(vc, animated: true)

		cell?.unBindViewModel()
		viewModel = nil
		viewController = nil
	}
}
