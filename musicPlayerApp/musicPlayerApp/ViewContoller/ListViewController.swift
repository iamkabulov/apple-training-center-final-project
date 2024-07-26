//
//  ListViewController.swift
//  musicPlayerApp
//
//  Created by Nursultan Kabulov on 13.07.2024.
//

import UIKit

final class ListViewController: UIViewController {

	static var headerKind: String {
		return String(describing: self)
	}
	
	enum Spacing {
		static let aboveMiniPlayer: CGFloat = 64
	}

	var viewModel: ListViewModel?
	var item: SPTAppRemoteContentItem?
	var items: [SPTAppRemoteContentItem]?
	var topTracks: [TopTrack]?
	var libraryStates: [String: SPTAppRemoteLibraryState]?
	var artistItem: SPTAppRemoteArtist?
	private lazy var collectionView: CustomCollectionView = {
		let collectionView = CustomCollectionView()
		collectionView.register(ListCell.self, forCellWithReuseIdentifier: ListCell.reuseIdentifier)
		collectionView.register(HeaderView.self,
								forSupplementaryViewOfKind: ListViewController.headerKind,
								withReuseIdentifier: HeaderView.reuseIdentifier)

		collectionView.dataSource = self
		collectionView.delegate = self
		floatingHeaderView.translatesAutoresizingMaskIntoConstraints = false
		floatingHeaderView.isFloating = true
		return collectionView
	}()

	enum Action {
		static let addMessage = "добавлен в избранное"
		static let removeMessage = "удален из избранных"
	}

	var headerView: HeaderView?
	var floatingHeaderView = HeaderView()

	init(item: SPTAppRemoteContentItem) {
		super.init(nibName: nil, bundle: nil)
		self.viewModel = ListViewModel(self)
		self.title = item.title
		self.item = item
		self.floatingHeaderView.set(data: item)
	}

	init(artistItem: SPTAppRemoteArtist) {
		super.init(nibName: nil, bundle: nil)
		self.viewModel = ListViewModel(self)
		self.artistItem = artistItem
	}

	init() {
		super.init(nibName: nil, bundle: nil)
		self.viewModel = ListViewModel(self)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		layout()
		fetchData()
		self.navigationController?.navigationBar.topItem?.title = ""
		bindViewModel()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.navigationController?.setNavigationBarHidden(false, animated: animated)
		self.viewModel?.network.appRemote.delegate = self /// если что вернуть
		self.viewModel?.network.appRemote.playerAPI?.delegate = self
		refreshData()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
	}

	deinit {
		clearResources()
		self.navigationController?.popViewController(animated: true)
		print("ListViewController deinitialized")
	}

	private func refreshData() {
		fetchData()
		bindViewModel()
	}

	private func fetchData() {
		if let artist = artistItem {
			floatingHeaderView.set(artist: artist)
			viewModel?.getArtistDetails(with: artist)
			viewModel?.getTopTracks(with: artist)
		} else if let item = item {
			viewModel?.getListOf(content: item)
			viewModel?.getPoster(for: item)
		} else {
			viewModel?.getItem()
		}
		self.viewModel?.subscribeToState()
	}

	private func updateCollectionView() {
		collectionView.updateData(items: items, topTracks: topTracks, libraryStates: libraryStates, artistItem: artistItem)
	}

	func bindViewModel() {
		self.viewModel?.childrenOfContent.bind { [weak self] items in
			DispatchQueue.main.async {
				self?.items = items
				self?.updateCollectionView()
			}
		}

		self.viewModel?.trackPoster.bind { [weak self] img in
			DispatchQueue.main.async {
				guard let image = img else { return }
				self?.floatingHeaderView.set(image: image)
			}
		}

		self.viewModel?.libraryStates.bind { [weak self] states in
			self?.libraryStates = states
			self?.updateCollectionView()
		}

		self.viewModel?.item.bind { [weak self] item in
			guard let item = item else { return }
			self?.item = item
			self?.floatingHeaderView.set(data: item)
			self?.fetchData()
		}

		self.viewModel?.details.bind { [weak self] details in
			self?.viewModel?.getPoster(url: details?.images[0].url ?? "")
		}

		self.viewModel?.artistPoster.bind { [weak self] image in
			guard let image = image else { return }
			self?.floatingHeaderView.set(image: image)
		}

		self.viewModel?.topTracks.bind { [weak self] tracks in
			self?.topTracks = tracks?.tracks
			self?.updateCollectionView()
		}

		self.viewModel?.isAdded.bind { [weak self] value in
			DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
				self?.updateCollectionView()
			}
		}

		self.viewModel?.isRemoved.bind { [weak self] value in
			DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
				self?.updateCollectionView()
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

	func clearResources() {
		viewModel?.network.appRemote.delegate = nil
		viewModel?.trackPoster.unbind()
		viewModel?.childrenOfContent.unbind()
		viewModel?.libraryStates.unbind()
		viewModel?.item.unbind()
		viewModel?.details.unbind()
		viewModel?.artistPoster.unbind()
		viewModel?.topTracks.unbind()
		viewModel?.isAdded.unbind()
		viewModel?.isRemoved.unbind()
		items = nil
		topTracks = nil
		viewModel = nil
	}
}

// MARK: Layout
extension ListViewController {
	func layout() {
		view.backgroundColor = .systemBackground
		view.addSubview(collectionView)
		view.addSubview(floatingHeaderView)

		NSLayoutConstraint.activate([
			collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Spacing.aboveMiniPlayer),

			floatingHeaderView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			floatingHeaderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
		])
	}
}


extension ListViewController: SPTAppRemoteDelegate {
	func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
		print("1")
	}

	func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
		print("2")
	}

	func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
		print("3")
		viewModel?.network.appRemote.delegate = nil
		viewModel = nil
		if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate {
			let vc = LogInViewController()
			sceneDelegate.switchRoot(vc: vc)
		}
	}
}

extension ListViewController: SPTAppRemotePlayerStateDelegate {
	func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
		debugPrint("Spotify Track name: %@", playerState.track.name)
		if let vc = tabBarController as? MusicBarController {
			vc.playerStateDidChange(playerState)
		}
	}
}
