//
//  Observable.swift
//  musicPlayerApp
//
//  Created by Nursultan Kabulov on 09.07.2024.
//

import Foundation

final class Observable<T> {

	var value: T? {
		didSet {
			DispatchQueue.main.async {
				self.listener?(self.value)
			}
		}
	}
	private var listener: ((T?) -> Void)?

	init(_ value: T? = nil) {
		self.value = value
	}

	func bind(_ listener: @escaping ((T?) -> Void)) {
		listener(value)
		self.listener = listener
	}
}
final class ObservableDictionary<Key: Hashable, Value> {

	var dictionary: [Key: Value] {
		didSet {
			DispatchQueue.main.async {
				self.listener?(self.dictionary)
			}
		}
	}

	private var listener: (([Key: Value]) -> Void)?

	init(_ value: [Key: Value] = [:]) {
		self.dictionary = value
	}

	func bind(_ listener: @escaping (([Key: Value]) -> Void)) {
		self.listener = listener
		listener(dictionary)
	}

	func updateValue(_ value: Value, forKey key: Key) {
		self.dictionary[key] = value
		listener?(dictionary)
	}

	func value(forKey key: Key) -> Value? {
		return self.dictionary[key]
	}
}
