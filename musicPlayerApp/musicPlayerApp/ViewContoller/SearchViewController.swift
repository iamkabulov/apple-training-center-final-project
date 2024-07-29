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
	private var libraryStates: [String: SPTAppRemoteLibraryState]?
	private var dataSource: [Item]?

	enum Action {
		static let addMessage = "добавлен в избранное"
		static let removeMessage = "удален из избранных"
	}

	private enum Spacing {
		enum Size {
			static let height: CGFloat = 150
			static let width: CGFloat = 150
		}
		static let small: CGFloat = 4
		static let medium: CGFloat = 10
		static let miniPlayerOffset: CGFloat = 64
	}

	//MARK: - SearchView
	private lazy var searchField: UISearchTextField = {
		let input = UISearchTextField()
		input.translatesAutoresizingMaskIntoConstraints = false
		input.autocorrectionType = .no
		input.tintColor = .black
		input.delegate = self
		input.placeholder = "Что хочешь послушать?"
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

	private lazy var imageView: UIImageView = {
		return ImageViewBuilder()
			.setImage(named: "music-note-svgrepo-com")
			.setContentMode(.scaleAspectFit)
			.build()
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
//		bindViewModel()
		self.viewModel?.network.appRemote.playerAPI?.delegate = self
		self.viewModel?.subscribeToState()
		self.navigationController?.setNavigationBarHidden(true, animated: animated)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.hideKeyboardWhenTappedAround() 
		self.imageView.alpha = 0.5
		view.backgroundColor = .systemBackground
		self.layout()
		self.bindViewModel()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
//		self.bindViewModel()
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
	}

	deinit {
		clearResources()
		print("DEINIT SEARCH VIEW")
	}

	func clearResources() {
		viewModel?.items.unbind()
		viewModel?.isAdded.unbind()
		viewModel?.isRemoved.unbind()
		viewModel?.libraryStates.unbind()
	}
}

extension SearchViewController {
	func layout() {
		stackView.addSubview(tableView)
		stackView.addSubview(searchField)
		stackView.addSubview(imageView)

		view.addSubview(stackView)

		NSLayoutConstraint.activate([
			stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
			stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
			stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

			tableView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: Spacing.medium),
			tableView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
			tableView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: -Spacing.miniPlayerOffset),

			searchField.topAnchor.constraint(equalTo: stackView.topAnchor, constant: Spacing.medium),
			searchField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.medium),
			searchField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.medium),

			imageView.centerYAnchor.constraint(equalTo: stackView.centerYAnchor),
			imageView.centerXAnchor.constraint(equalTo: stackView.centerXAnchor),
			imageView.heightAnchor.constraint(equalToConstant: Spacing.Size.height),
			imageView.widthAnchor.constraint(equalToConstant: Spacing.Size.width)
		])
	}

	//MARK: - Binding ViewModel
	func bindViewModel() {
		self.viewModel?.items.bind { [weak self] content in
			self?.dataSource = content
			self?.tableView.reloadData()
		}

		self.viewModel?.libraryStates.bind { [weak self] states in
			self?.libraryStates = states
			self?.tableView.reloadData()
		}

		self.viewModel?.isAdded.bind { [weak self] value in
			DispatchQueue.main.async {
				self?.tableView.reloadData()
			}
		}

		self.viewModel?.isRemoved.bind { [weak self] value in
			DispatchQueue.main.async{
				self?.tableView.reloadData()
			}
		}
	}

	func showAlert(on viewController: UIViewController, title: String, withMessage: String) {
		let alert = UIAlertController(title: title, message: withMessage, preferredStyle: .alert)
		viewController.present(alert, animated: true) {
			DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
				alert.dismiss(animated: true, completion: nil)
			}
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
	}

	func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
		print("Disconnected With Error")
		clearResources()
		viewModel?.network.appRemote.delegate = nil
		viewModel = nil
		if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate {
			let vc = LogInViewController()
			sceneDelegate.switchRoot(vc: vc)
		}
	}
}

//MARK: - UITableViewDelegate & UITableViewDataSource
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let data = dataSource else {
			imageView.isHidden = false
			return 0
		}
		imageView.isHidden = true
		return  data.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchedItemCell.identifier, for: indexPath) as? SearchedItemCell, let items = dataSource else { return UITableViewCell() }

		self.viewModel?.network.fetchArtistImage(url: items[indexPath.row].album?.images?[0].url ?? "", completionHandler: { image in
			DispatchQueue.main.async {
				cell.setImage(data: image)
			}
		})
		viewModel?.getTrackState(uri: items[indexPath.row].uri)

		if let state = libraryStates?[items[indexPath.row].uri] {
			cell.changeButtonState(state.isAdded)
			cell.addRemoveButtonTappedHandler = { [weak self, weak cell] in
				guard let self = self, let cell = cell else { return }
				if state.isAdded {
					self.viewModel?.removeFromLibrary(uri: items[indexPath.row].uri)
					cell.changeButtonState(false)
					self.showAlert(on: self, title: items[indexPath.row].name ?? "Music", withMessage: Action.removeMessage)
				}
				else {
					self.viewModel?.addToLibrary(uri: items[indexPath.row].uri)
					cell.changeButtonState(true)
					self.showAlert(on: self, title: items[indexPath.row].name ?? "Music", withMessage: Action.addMessage)
				}
			}
		}

		cell.configure(item: items[indexPath.row])
		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let uri = self.dataSource?[indexPath.row].uri else { return }
		print(uri)
		self.viewModel?.play(trackUri: uri)
		tableView.deselectRow(at: indexPath, animated: true)
	}
}

extension SearchViewController: SPTAppRemotePlayerStateDelegate {
	func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
		debugPrint("Spotify Track name: %@", playerState.track.name)
		if let vc = tabBarController as? MusicBarController {
			vc.playerStateDidChange(playerState)
		}
	}
}

extension SearchViewController: UITextFieldDelegate {

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		guard let title = textField.text else { return true }
		if title == "" {
			imageView.isHidden = false
			dataSource = nil
			tableView.reloadData()
		} else {
			viewModel?.search(title)
		}

		textField.resignFirstResponder()
		return true
	}
}
