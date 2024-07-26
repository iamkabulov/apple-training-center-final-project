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
	private lazy var buttonConfiguration = UIImage.SymbolConfiguration(pointSize: 22, weight: .light, scale: .default)
	private lazy var minusImage = UIImage(systemName: "minus", withConfiguration: self.buttonConfiguration)
	private lazy var plusImage = UIImage(systemName: "plus", withConfiguration: self.buttonConfiguration)
	var addRemoveButtonTappedHandler: (() -> Void)?

	private enum Spacing {
		enum Size {
			static let height: CGFloat = 50
			static let width: CGFloat = 50
			static let thickness: CGFloat = 0.5
		}
		static let small: CGFloat = 4
		static let medium: CGFloat = 8
		static let large: CGFloat = 16
	}
	//MARK: - StackViews
	private lazy var vStackView: UIStackView = {
		let stack = UIStackView()
		stack.addSubview(albumImageView)
		stack.addSubview(titleLabel)
		stack.addSubview(artistLabel)
		stack.addSubview(addToLibraryButton)
		stack.addSubview(seperatorView)
		stack.translatesAutoresizingMaskIntoConstraints = false
		stack.axis = .vertical
		stack.spacing = .zero
		return stack
	}()

	private lazy var titleLabel: UILabel = {
		return LabelBuilder()
			.setFont(UIFont.systemFont(ofSize: 18, weight: .bold))
			.setTextAlignment(.left)
			.build()
	}()

	private lazy var artistLabel: UILabel = {
		return LabelBuilder()
			.setFont(UIFont.systemFont(ofSize: 16, weight: .regular))
			.setTextAlignment(.left)
			.setTextColor(.systemGray)
			.build()
	}()

	lazy var albumImageView: UIImageView = {
		return ImageViewBuilder()
			.setClipsToBounds(true)
			.setContentMode(.scaleAspectFill)
			.setImage(named: "stpGreenIcon")
			.build()
	}()

	private lazy var addToLibraryButton: UIButton = {
		return ButtonBuilder()
			.setImage(plusImage, for: .normal)
			.setTintColor(.black)
			.addTarget(self, action: #selector(addRemoveButtonTapped), for: .touchUpInside)
			.build()
	}()

	private lazy var seperatorView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .systemGray
		return view
	}()

	//MARK: - ViewLifeCycle
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupLayout()
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		self.albumImageView.image = nil
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	//MARK: - Methods
	func configure(item: Item) {
		titleLabel.text = item.name

		if let artists = item.artists, artists.count >= 1 {
			for artist in artists {
				artistLabel.text = artist.name
			}
		}
	}

	func setImage(data: UIImage) {
		self.albumImageView.image = data
	}

	@objc func addRemoveButtonTapped() {
		addRemoveButtonTappedHandler?()
	}

	func changeButtonState(_ value: Bool) {
		if value {
			addToLibraryButton.setImage(minusImage, for: .normal)
		} else {
			addToLibraryButton.setImage(plusImage, for: .normal)
		}
	}

}

//MARK: - SectionCell
private extension SearchedItemCell {
	func setupLayout() {
		contentView.addSubview(vStackView)
		NSLayoutConstraint.activate([
			vStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
			vStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			vStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			vStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

			albumImageView.leadingAnchor.constraint(equalTo: vStackView.leadingAnchor, constant: Spacing.large),
			albumImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
			albumImageView.widthAnchor.constraint(equalToConstant: Spacing.Size.width),
			albumImageView.heightAnchor.constraint(equalToConstant: Spacing.Size.height),

			titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Spacing.medium),
			titleLabel.leadingAnchor.constraint(equalTo: albumImageView.trailingAnchor, constant: Spacing.large),
			titleLabel.trailingAnchor.constraint(equalTo: addToLibraryButton.leadingAnchor, constant: Spacing.medium),

			artistLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Spacing.medium),
			artistLabel.leadingAnchor.constraint(equalTo: albumImageView.trailingAnchor, constant: Spacing.large),
			artistLabel.trailingAnchor.constraint(equalTo: addToLibraryButton.leadingAnchor, constant: Spacing.medium),

			addToLibraryButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			addToLibraryButton.widthAnchor.constraint(equalToConstant: Spacing.Size.width),
			addToLibraryButton.heightAnchor.constraint(equalToConstant: Spacing.Size.height),
			addToLibraryButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Spacing.medium),

			seperatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Spacing.large),
			seperatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			seperatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Spacing.large),
			seperatorView.heightAnchor.constraint(equalToConstant: Spacing.Size.thickness)
		])
	}
}
