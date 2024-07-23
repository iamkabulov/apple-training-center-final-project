//
//  SearchViewController.swift
//  musicPlayerApp
//
//  Created by Nursultan Kabulov on 19.07.2024.
//

import UIKit

final class SearchViewController: UIViewController {
	var viewModel: SearchViewModel?
	private var currentTime: Double = 0
	private var lastPlayerState: SPTAppRemotePlayerState?
	private var dataSource: [Item]?

	//MARK: - SearchView
	private lazy var searchField: UISearchTextField = {
		let input = UISearchTextField()
		input.translatesAutoresizingMaskIntoConstraints = false
		input.autocorrectionType = .no
		input.tintColor = .black
		input.delegate = self
		input.placeholder = "Search"
		return input
	}()

	private lazy var tableView: UITableView = {
		let view = UITableView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.separatorStyle = .none
		view.register(SearchedItemCell.self, forCellReuseIdentifier: SearchedItemCell.identifier)
		view.delegate = self
		view.rowHeight = SearchedItemCell.rowHeight
		view.dataSource = self
		return view
	}()

	private lazy var stackView: UIStackView = {
		let stackView = UIStackView()
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical
		stackView.spacing = 20
		stackView.alignment = .center
		return stackView
	}()

	//MARK: - View LifeCycle
	init() {
		super.init(nibName: nil, bundle: nil)
		self.viewModel = SearchViewModel(self)
		viewModel?.authForSearch()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.hideKeyboardWhenTappedAround() 
		view.backgroundColor = .systemBackground
		self.layout()
		self.bindViewModel()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		self.bindViewModel()
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		viewModel?.items.unbind()
	}
}

extension SearchViewController {
	func layout() {
		stackView.addSubview(tableView)
		stackView.addSubview(searchField)

		view.addSubview(stackView)

		NSLayoutConstraint.activate([
			stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
			stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
			stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

			tableView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 10),
			tableView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
			tableView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor),

			searchField.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 10),
			searchField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
			searchField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
		])
	}

	//MARK: - Binding ViewModel
	func bindViewModel() {
		self.viewModel?.items.bind { [weak self] content in
			self?.dataSource = content
			self?.tableView.reloadData()
		}
	}
}
//MARK: - SPTAppRemoteDelegate
extension SearchViewController: SPTAppRemoteDelegate {
	func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
		print("Connected ")
//		self.viewModel?.getContentItems()
		self.tableView.reloadData()
	}

	func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
		print("Failed")
		viewModel?.network.appRemote.delegate = nil
		let vc = LogInViewController()
		vc.modalPresentationStyle = .fullScreen
		self.present(vc, animated: true)
	}

	func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
		print("Disconnected With Error")
		viewModel?.network.appRemote.delegate = nil
		let vc = LogInViewController()
		vc.modalPresentationStyle = .fullScreen
		self.present(vc, animated: true)
	}
}

//MARK: - UITableViewDelegate & UITableViewDataSource
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return dataSource?.count ?? 0
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchedItemCell.identifier, for: indexPath) as? SearchedItemCell,
			let items = dataSource
		else { return UITableViewCell() }
		cell.setData(item: items[indexPath.row])
		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let uri = self.dataSource?[indexPath.row].uri else { return }
		print(uri)
		self.viewModel?.network.play(trackUri: uri)
		tableView.deselectRow(at: indexPath, animated: true)
	}
}

extension SearchViewController: UITextFieldDelegate {

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		guard let title = textField.text else { return true }
		if title == "" {
			//пусто
		} else {
			viewModel?.search(title)
		}

		textField.resignFirstResponder()
		return true
	}
}
