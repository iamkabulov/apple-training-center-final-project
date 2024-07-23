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
	var viewModel: ListViewModel?
	var vc: MusicBarController?
	private var item: SPTAppRemoteContentItem?
	private var items: [SPTAppRemoteContentItem]?
	private var libraryStates: [String: SPTAppRemoteLibraryState]?
	var collectionView: UICollectionView! = nil

	private enum Action {
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
//		self.vc = vc
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
		guard let item = self.item else {
			viewModel?.getItem()
			return
		}
		self.viewModel?.getListOf(content: item)
		self.viewModel?.getPoster(for: item)
		self.navigationController?.navigationBar.topItem?.title = ""
		bindViewModel()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.navigationController?.setNavigationBarHidden(false, animated: animated)

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
		viewModel?.network.appRemote.delegate = nil
		viewModel = nil
		self.navigationController?.popViewController(animated: true)
	}

	deinit {
		viewModel?.trackPoster.unbind()
		viewModel?.childrenOfContent.unbind()
		viewModel?.libraryStates.unbind()
		viewModel?.network.appRemote.delegate = nil
		viewModel = nil
		items = nil
		viewModel?.item.unbind()
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
			self?.floatingHeaderView.set(data: item)
			self?.viewModel?.getListOf(content: item)
			self?.viewModel?.getPoster(for: item)
		}
	}

	func showAlert(on viewController: UIViewController, title: String, withMessage: String) {
		let alert = UIAlertController(title: title, message: withMessage, preferredStyle: .alert)
		viewController.present(alert, animated: true) {
			// Закрытие алерта через 2 секунды
			DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
				alert.dismiss(animated: true, completion: nil)
			}
		}
	}
}

// MARK: Layout
extension ListViewController {

	func layout() {
		view.backgroundColor = .systemBackground
		// Collection View
		collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		collectionView.backgroundColor = .systemBackground

		view.addSubview(collectionView)

		NSLayoutConstraint.activate([
			collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -64),
		])

		collectionView.register(ListCell.self, forCellWithReuseIdentifier: ListCell.reuseIdentifier)
		collectionView.register(HeaderView.self,
								forSupplementaryViewOfKind: ListViewController.headerKind,
								withReuseIdentifier: HeaderView.reuseIdentifier)

		collectionView.dataSource = self
		collectionView.delegate = self

		// Floating header view
		floatingHeaderView.translatesAutoresizingMaskIntoConstraints = false

		view.addSubview(floatingHeaderView)

		floatingHeaderView.isFloating = true
		NSLayoutConstraint.activate([
			floatingHeaderView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			floatingHeaderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
		])

	}

	func createLayout() -> UICollectionViewLayout {

		// ListCell layout
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
											 heightDimension: .fractionalHeight(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
											  heightDimension: .absolute(44))
		let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

		let section = NSCollectionLayoutSection(group: group)
		section.interGroupSpacing = 5
		section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)

		// Header layout
		let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
													 heightDimension: .estimated(300))
		let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
			layoutSize: headerFooterSize,
			elementKind: ListViewController.headerKind, alignment: .top)

		section.boundarySupplementaryItems = [sectionHeader]

		let layout = UICollectionViewCompositionalLayout(section: section)
		return layout
	}
}

extension ListViewController: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let viewModel = self.viewModel else { return 0 }
		return viewModel.getCount()
	}

	// ListCell
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(
			withReuseIdentifier: ListCell.reuseIdentifier,
			for: indexPath) as! ListCell
		
		guard let item = items?[indexPath.row] else { return cell }
		cell.set(title: item.title)
		viewModel?.getTrackState(uri: item.uri)
		if let state = libraryStates?[item.uri] {
			cell.changeButtonState(state.isAdded)
			cell.addRemoveButtonTappedHandler = { [weak self, weak cell] in
				guard let self = self, let cell = cell else { return }
				if state.isAdded {
					self.viewModel?.removeFromLibrary(uri: item.uri)
					cell.changeButtonState(false)
					self.showAlert(on: self, title: item.title ?? "Music", withMessage: Action.removeMessage)
				}
				else {
					self.viewModel?.addToLibrary(uri: item.uri)
					cell.changeButtonState(true)
					self.showAlert(on: self, title: item.title ?? "Music", withMessage: Action.addMessage)
				}
			}
		}
		return cell
	}

	// HeaderView
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		let headerView = collectionView.dequeueReusableSupplementaryView(
			ofKind: kind,
			withReuseIdentifier: HeaderView.reuseIdentifier,
			for: indexPath) as! HeaderView


		self.headerView = headerView
		self.headerView?.isHidden = true

		return headerView
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let item = self.items?[indexPath.row] else { return }
		self.viewModel?.play(item: item)
	}
}

extension ListViewController: UICollectionViewDelegateFlowLayout {

	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		headerView?.scrollViewDidScroll(scrollView)
		floatingHeaderView.scrollViewDidScroll(scrollView)
	}
}

extension ListViewController: SPTAppRemoteDelegate {
	func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
		print("1")
	}

	func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
		print("2")
		viewModel?.network.appRemote.delegate = nil
		let vc = LogInViewController()
		vc.modalPresentationStyle = .fullScreen
//		self.present(vc, animated: true)
	}

	func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
		print("3")
		viewModel?.network.appRemote.delegate = nil
		let vc = LogInViewController()
		vc.modalPresentationStyle = .fullScreen
//		self.present(vc, animated: true)
	}
}
