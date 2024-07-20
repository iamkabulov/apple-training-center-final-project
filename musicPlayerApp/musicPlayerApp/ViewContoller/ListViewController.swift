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
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		layout()
		guard let item = self.item else { return }
		self.viewModel?.getListOf(content: item)
		self.viewModel?.getPoster(for: item)
		self.navigationController?.navigationBar.topItem?.title = ""
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		bindViewModel()
	}

	func bindViewModel() {
		self.viewModel?.childrenOfContent.bind { items in
			DispatchQueue.main.async {
				self.items = items
				self.collectionView.reloadData()
			}
		}

		self.viewModel?.trackPoster.bind { img in
			DispatchQueue.main.async {
				guard let image = img else { return }
				self.floatingHeaderView.set(image: image)
			}
		}

		self.viewModel?.libraryStates.bind { states in
			self.libraryStates = states
			self.collectionView.reloadData()
		}
	}

	func showAlert(on viewController: UIViewController) {
		let alert = UIAlertController(title: "Music", message: "has been added", preferredStyle: .alert)
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
			collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
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
													 heightDimension: .estimated(250))
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
		
		guard let item = items?[indexPath.item] else { return cell }
		viewModel?.getTrackState(uri: item.uri)
		cell.set(title: item.title)
		
		if let state = libraryStates?[item.uri] {
			cell.changeButtonState(state.isAdded)
			if state.isAdded {
				cell.addRemoveButtonTappedHandler = {
					self.viewModel?.removeFromLibrary(uri: item.uri)
					self.viewModel?.getTrackState(uri: item.uri)
					self.showAlert(on: self)
					cell.changeButtonState(false)
				}
			} else {
				cell.addRemoveButtonTappedHandler = {
					self.viewModel?.addToLibrary(uri: item.uri)
					self.viewModel?.getTrackState(uri: item.uri)
					self.showAlert(on: self)
					cell.changeButtonState(true)
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
		self.viewModel?.network.play(item: item)
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
		self.present(vc, animated: true)
	}

	func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
		print("3")
		viewModel?.network.appRemote.delegate = nil
		let vc = LogInViewController()
		vc.modalPresentationStyle = .fullScreen
		self.present(vc, animated: true)
	}
}
