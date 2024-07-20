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

	var addRemoveButtonTappedHandler: (() -> Void)?
	private lazy var label: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.adjustsFontForContentSizeCategory = true
		label.font = UIFont.preferredFont(forTextStyle: .body)
		label.textColor = .label
		label.adjustsFontSizeToFitWidth = true
		return label
	}()
	
	private lazy var accessoryImageView: UIImageView = {
		let imageView = UIImageView()

		imageView.translatesAutoresizingMaskIntoConstraints = false
		let rtl = effectiveUserInterfaceLayoutDirection == .rightToLeft
		let chevronImageName = rtl ? "chevron.left" : "chevron.right"
		let chevronImage = UIImage(systemName: chevronImageName)
		imageView.image = chevronImage
		imageView.tintColor = .systemGray
		return imageView
	}()

	private lazy var addToLibraryButton: UIButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		let buttonConfiguration = UIImage.SymbolConfiguration(pointSize: 22, weight: .light, scale: .default)
		button.setImage(UIImage(systemName: "plus",
								withConfiguration: buttonConfiguration),
						for: .normal)
		button.tintColor = .black
		button.addTarget(self, action: #selector(addRemoveButtonTapped), for: .touchUpInside)
		return button
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
	}
}

extension ListCell {
	func layout() {
		contentView.addSubview(self.seperatorView)
		contentView.addSubview(self.label)
		contentView.addSubview(self.addToLibraryButton)

		let inset = CGFloat(10)
		NSLayoutConstraint.activate([
			label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: inset),
			label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
			label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -inset),
			label.trailingAnchor.constraint(equalTo: addToLibraryButton.leadingAnchor, constant: -inset),

			addToLibraryButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			addToLibraryButton.widthAnchor.constraint(equalToConstant: 30),
			addToLibraryButton.heightAnchor.constraint(equalToConstant: 30),
			addToLibraryButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
			
			seperatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
			seperatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			seperatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
			seperatorView.heightAnchor.constraint(equalToConstant: 0.5)
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
			let buttonConfiguration = UIImage.SymbolConfiguration(pointSize: 22, weight: .light, scale: .default)
			addToLibraryButton.setImage(UIImage(systemName: "minus",
									withConfiguration: buttonConfiguration),
							for: .normal)
		} else {
			let buttonConfiguration = UIImage.SymbolConfiguration(pointSize: 22, weight: .light, scale: .default)
			addToLibraryButton.setImage(UIImage(systemName: "plus",
									withConfiguration: buttonConfiguration),
							for: .normal)
		}
	}
}
