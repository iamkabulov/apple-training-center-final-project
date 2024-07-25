//
//  LabelBuilder.swift
//  musicPlayerApp
//
//  Created by Nursultan Kabulov on 25.07.2024.
//

import Foundation

class LabelBuilder {
	private let label: UILabel

	init() {
		self.label = UILabel()
		self.label.translatesAutoresizingMaskIntoConstraints = false
		self.label.adjustsFontForContentSizeCategory = true
		self.label.adjustsFontSizeToFitWidth = true
	}

	func setFont(_ font: UIFont) -> LabelBuilder {
		self.label.font = font
		return self
	}

	func setTextAlignment(_ alignment: NSTextAlignment) -> LabelBuilder {
		self.label.textAlignment = alignment
		return self
	}

	func setTextColor(_ color: UIColor) -> LabelBuilder {
		self.label.textColor = color
		return self
	}

	func setNumberOfLines(_ lines: Int) -> LabelBuilder {
		self.label.numberOfLines = lines
		return self
	}

	func setText(_ text: String) -> LabelBuilder {
		self.label.text = text
		return self
	}

	func setTranslatesAutoresizingMaskIntoConstraints(_ flag: Bool) -> LabelBuilder {
		self.label.translatesAutoresizingMaskIntoConstraints = flag
		return self
	}

	func build() -> UILabel {
		return self.label
	}
}
