//
//  ListCell.swift
//  musicPlayerApp
//
//  Created by Nursultan Kabulov on 15.07.2024.
//

import UIKit

class ListCell: UICollectionViewCell {

	static var reuseIdentifier: String {
		return String(describing: self)
	}

	private lazy var buttonConfiguration = UIImage.SymbolConfiguration(pointSize: 22, weight: .light, scale: .default)
	private lazy var minusImage = UIImage(systemName: "minus", withConfiguration: self.buttonConfiguration)
	private lazy var plusImage = UIImage(systemName: "plus", withConfiguration: self.buttonConfiguration)

	private enum Spacing {
		enum Size {
			static let height: CGFloat = 30
			static let width: CGFloat = 30
			static let thickness: CGFloat = 0.5
		}
		static let small: CGFloat = 2
		static let medium: CGFloat = 10
		static let large: CGFloat = 20
	}

	var addRemoveButtonTappedHandler: (() -> Void)?
	
	private lazy var label: UILabel = {
		return LabelBuilder()
			.setFont(UIFont.systemFont(ofSize: 18, weight: .regular))
			.setTextColor(.label)
			.build()
	}()
	
	private lazy var accessoryImageView: UIImageView = {
		return ImageViewBuilder()
			.setImage(UIImage(systemName: "chevron.right"))
			.setColor(.systemGray)
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

	override init(frame: CGRect) {
		super.init(frame: frame)
		layout()
	}
	required init?(coder: NSCoder) {
		fatalError("not implemented")
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		addRemoveButtonTappedHandler = nil
	}

	deinit {
		print("List Cell deinited")
	}
}

extension ListCell {
	func layout() {
		contentView.addSubview(self.seperatorView)
		contentView.addSubview(self.label)
		contentView.addSubview(self.addToLibraryButton)

		NSLayoutConstraint.activate([
			label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Spacing.medium),
			label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Spacing.medium),
			label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Spacing.medium),
			label.trailingAnchor.constraint(equalTo: addToLibraryButton.leadingAnchor, constant: -Spacing.medium),

			addToLibraryButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			addToLibraryButton.widthAnchor.constraint(equalToConstant: Spacing.Size.width),
			addToLibraryButton.heightAnchor.constraint(equalToConstant: Spacing.Size.height),
			addToLibraryButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Spacing.medium),

			seperatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Spacing.medium),
			seperatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			seperatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Spacing.medium),
			seperatorView.heightAnchor.constraint(equalToConstant: Spacing.Size.thickness)
		])
	}

	func set(title: String?) {
		label.text = title
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
