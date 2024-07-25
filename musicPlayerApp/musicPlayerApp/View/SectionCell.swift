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
		return LabelBuilder()
			.setFont(UIFont.systemFont(ofSize: 24, weight: .bold))
			.setNumberOfLines(0)
			.setTextAlignment(.left)
			.build()
	}()

	private lazy var recommendationCollectionView = RecommendationCollectionView()

	//MARK: - ViewLifeCycle
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupLayout()
		self.selectionStyle = .none
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		viewController = nil
		viewModel = nil
		dataSource = nil
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	deinit {
		print("SECTIONCELL DEINIT")
	}

	//MARK: - Methods
	func setData(viewController controller: MainViewController, viewModel vm: MainViewModel, data: SPTAppRemoteContentItem) {
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
		}
		self.recommendationCollectionView.setData(viewController: controller, viewModel: vm, data: data)
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
