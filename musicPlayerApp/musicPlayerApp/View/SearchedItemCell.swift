//
//  SearchedItemCell.swift
//  musicPlayerApp
//
//  Created by Nursultan Kabulov on 19.07.2024.
//
import UIKit

final class SearchedItemCell: UITableViewCell {

	//MARK: - Properties
	static var identifier: String {
		return String(describing: self)
	}
	static let rowHeight: CGFloat = 70

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
		stack.addSubview(artistLabel)
		stack.translatesAutoresizingMaskIntoConstraints = false
//		stack.backgroundColor = .red
		stack.axis = .vertical
		stack.spacing = .zero
		return stack
	}()

	private lazy var titleLabel: UILabel = {
		let trackLabel = UILabel()
		trackLabel.translatesAutoresizingMaskIntoConstraints = false
		trackLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
		trackLabel.text = "Song"
		trackLabel.textAlignment = .left
		return trackLabel
	}()

	private lazy var artistLabel: UILabel = {
		let trackLabel = UILabel()
		trackLabel.translatesAutoresizingMaskIntoConstraints = false
		trackLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
		trackLabel.text = "Artist"
		trackLabel.textAlignment = .left
		return trackLabel
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
	func setData(item: Item) {
		titleLabel.text = item.name

		if let artists = item.artists, artists.count >= 1 {
			for artist in artists {
				artistLabel.text = artist.name
			}
		}
	}
}

//MARK: - SectionCell
private extension SearchedItemCell {
	func setupLayout() {
		contentView.addSubview(vStackView)
		NSLayoutConstraint.activate([
			vStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
			vStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Spacing.large),
			vStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			vStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: Spacing.large),

			titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Spacing.medium),
			titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Spacing.large),

			artistLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Spacing.medium),
			artistLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Spacing.large),
		])
	}
}
