//
//  MainTableView.swift
//  musicPlayerApp
//
//  Created by Nursultan Kabulov on 25.07.2024.
//

import UIKit

final class MainTableView: UITableView, UITableViewDelegate, UITableViewDataSource {

	private weak var viewModel: MainViewModel?
	private weak var viewController: MainViewController?
	private var data: [SPTAppRemoteContentItem]?

	init(viewModel: MainViewModel?, viewController: MainViewController?) {
		self.viewModel = viewModel
		self.viewController = viewController
		super.init(frame: .zero, style: .plain)
		self.translatesAutoresizingMaskIntoConstraints = false
		self.separatorStyle = .none
		self.register(SectionCell.self, forCellReuseIdentifier: SectionCell.identifier)
		self.delegate = self
		self.rowHeight = SectionCell.rowHeight
		self.dataSource = self
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func updateDataSource(_ dataSource: [SPTAppRemoteContentItem]) {
		self.data = dataSource
		self.reloadData()
	}

	//MARK: - UITableViewDelegate & UITableViewDataSource
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let data = data else { return 0 }
		return data.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: SectionCell.identifier, for: indexPath) as? SectionCell else { return UITableViewCell() }
		guard let data = self.data,
			  let viewModel = self.viewModel,
			  let viewController = self.viewController else { return cell }
		cell.setData(viewController: viewController, viewModel: viewModel, data: data[indexPath.row])
		return cell
	}
}

