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
	var vc: MusicBarController?
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
		static let addMessage = "has been added to favourite library"
		static let removeMessage = "has been removed from favourite library"
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
		if let artist = self.artistItem {
			self.floatingHeaderView.set(artist: artist)
			viewModel?.getArtistDetails(with: artist)
			viewModel?.getTopTracks(with: artist)
		} else {
			guard let item = self.item else {
				viewModel?.getItem()
				return
			}
			self.viewModel?.getListOf(content: item)
			self.viewModel?.getPoster(for: item)
		}
		self.navigationController?.navigationBar.topItem?.title = ""
		bindViewModel()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.navigationController?.setNavigationBarHidden(false, animated: animated)
		self.viewModel = ListViewModel(self)
		if let artistItem = self.artistItem {
			self.floatingHeaderView.set(artist: artistItem)
			viewModel?.getArtistDetails(with: artistItem)
			viewModel?.getTopTracks(with: artistItem)
			return
		}
		if let viewModel = viewModel {
			if let item = self.item  {
				viewModel.getListOf(content: item)
				viewModel.getPoster(for: item)
			} else {
				viewModel.getItem()
			}
		} else {
			self.viewModel = ListViewModel(self)
			if let item = self.item  {
				self.viewModel?.getListOf(content: item)
				self.viewModel?.getPoster(for: item)
			} else {
				self.viewModel?.getItem()
			}
		}
		bindViewModel()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		bindViewModel()
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		viewModel?.trackPoster.unbind()
		viewModel?.childrenOfContent.unbind()
		viewModel?.libraryStates.unbind()
		viewModel?.item.unbind()
		viewModel?.details.unbind()
		viewModel?.artistPoster.unbind()
		viewModel?.topTracks.unbind()
		viewModel?.network.appRemote.delegate = nil
		viewModel = nil
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
	}

	deinit {
		viewModel?.trackPoster.unbind()
		viewModel?.childrenOfContent.unbind()
		viewModel?.libraryStates.unbind()
		viewModel?.network.appRemote.delegate = nil
		viewModel = nil
		items = nil
		topTracks = nil
		viewModel?.item.unbind()
		viewModel?.details.unbind()
		viewModel?.artistPoster.unbind()
		viewModel?.topTracks.unbind()
		self.navigationController?.popViewController(animated: true)
		print("ListViewController deinitialized")
	}

	func bindViewModel() {
		self.viewModel?.childrenOfContent.bind { [weak self] items in
			DispatchQueue.main.async {
				self?.items = items
				self?.collectionView.reloadData()
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
			self?.collectionView.reloadData()
		}

		self.viewModel?.item.bind { [weak self] item in
			guard let item = item else { return }
			self?.item = item
			self?.title = item.title
			self?.floatingHeaderView.set(data: item)
			self?.viewModel?.getListOf(content: item)
			self?.viewModel?.getPoster(for: item)
		}

		self.viewModel?.details.bind { [weak self] details in
			self?.viewModel?.getPoster(url: details?.images[0].url ?? "")
		}

		self.viewModel?.artistPoster.bind { [weak self] image in
			guard let image = image else { return }
			DispatchQueue.main.async {
				self?.floatingHeaderView.set(image: image)
			}
		}

		self.viewModel?.topTracks.bind { [weak self] tracks in
			guard let self = self else { return }
			DispatchQueue.main.async {
				self.topTracks = tracks?.tracks
				self.collectionView.reloadData()
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
//		viewModel?.network.appRemote.delegate = nil
//		let vc = LogInViewController()
//		vc.modalPresentationStyle = .fullScreen
//		self.present(vc, animated: true)
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
