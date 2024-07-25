//
//  CustomCollectionView.swift
//  musicPlayerApp
//
//  Created by Nursultan Kabulov on 25.07.2024.
//

import UIKit

final class CustomCollectionView: UICollectionView {

	private enum Spacing {
		enum inset {
			static let zero: CGFloat = 0
			static let small: CGFloat = 4
			static let medium: CGFloat = 10
			static let interSection: CGFloat = 5
		}
		enum ItemSize {
			static let heightDimension: CGFloat = 1
			static let widthDimension: CGFloat = 1
		}
		enum GroupSize {
			static let heightDimension: CGFloat = 44
			static let widthDimension: CGFloat = 1
		}
		enum HeaderSize {
			static let heightDimension: CGFloat = 300
			static let widthDimension: CGFloat = 1
		}
	}

	private weak var viewModel: ListViewModel?
	private weak var viewController: ListViewController?
	private var items: [SPTAppRemoteContentItem] = []
	private var topTracks: [TopTrack] = []
	private var libraryStates: [String: SPTAppRemoteLibraryState] = [:]
	private var artistItem: SPTAppRemoteArtist?

	init() {
		let layout = CustomCollectionView.createLayout()
		super.init(frame: .zero, collectionViewLayout: layout)
		self.translatesAutoresizingMaskIntoConstraints = false
		self.register(ListCell.self, forCellWithReuseIdentifier: ListCell.reuseIdentifier)
		self.register(HeaderView.self, forSupplementaryViewOfKind: ListViewController.headerKind, withReuseIdentifier: HeaderView.reuseIdentifier)
		self.backgroundColor = .systemBackground
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	static func createLayout() -> UICollectionViewLayout {
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(Spacing.ItemSize.widthDimension),
											  heightDimension: .fractionalHeight(Spacing.ItemSize.heightDimension))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(Spacing.GroupSize.widthDimension),
											   heightDimension: .absolute(Spacing.GroupSize.heightDimension))
		let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

		let section = NSCollectionLayoutSection(group: group)
		section.interGroupSpacing = Spacing.inset.interSection
		section.contentInsets = NSDirectionalEdgeInsets(top: Spacing.inset.zero,
														leading: Spacing.inset.medium,
														bottom: Spacing.inset.zero,
														trailing: Spacing.inset.medium)

		// Header layout
		let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(Spacing.HeaderSize.widthDimension),
													  heightDimension: .estimated(Spacing.HeaderSize.heightDimension))
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
		if artistItem != nil {
			return self.topTracks?.count ?? 0
		} else {
			return viewModel.getCount()
		}
	}

	// ListCell
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListCell.reuseIdentifier, for: indexPath) as! ListCell

		if let item = items?[indexPath.row] {
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
		if let item = topTracks?[indexPath.row] {
			cell.set(title: item.name)
			viewModel?.getTrackState(uri: item.uri)
			if let state = libraryStates?[item.uri] {
				cell.changeButtonState(state.isAdded)
				cell.addRemoveButtonTappedHandler = { [weak self, weak cell] in
					guard let self = self, let cell = cell else { return }
					if state.isAdded {
						self.viewModel?.removeFromLibrary(uri: item.uri)
						cell.changeButtonState(false)
						self.showAlert(on: self, title: item.name ?? "Music", withMessage: Action.removeMessage)
					}
					else {
						self.viewModel?.addToLibrary(uri: item.uri)
						cell.changeButtonState(true)
						self.showAlert(on: self, title: item.name ?? "Music", withMessage: Action.addMessage)
					}
				}
			}
			return cell
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
		if let item = self.items?[indexPath.row] {
			self.viewModel?.play(item: item)
		}
		if let track = self.topTracks?[indexPath.row] {
			self.viewModel?.network.play(trackUri: track.uri)
		}
	}
}

extension ListViewController: UICollectionViewDelegateFlowLayout {
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		headerView?.scrollViewDidScroll(scrollView)
		floatingHeaderView.scrollViewDidScroll(scrollView)
	}
}
