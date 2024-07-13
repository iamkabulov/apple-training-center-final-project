//
//  ListViewController.swift
//  musicPlayerApp
//
//  Created by Nursultan Kabulov on 13.07.2024.
//

import Foundation

final class ListViewController: UIViewController {

	init() {
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .blue
	}
}
