//
//  RecommendationCollectionView.swift
//  musicPlayerApp
//
//  Created by Nursultan Kabulov on 25.07.2024.
//

import UIKit

final class RecommendationCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout 
{
	private enum Spacing {
		enum Size {
			static let height: CGFloat = 170
			static let width: CGFloat = 130
		}
	}

	private weak var viewModel: MainViewModel?
	private var data: SPTAppRemoteContentItem?
	private weak var viewController: MainViewController?

	init() {
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .horizontal
		super.init(frame: .zero, collectionViewLayout: layout)
		self.showsHorizontalScrollIndicator = false
		self.dataSource = self
		self.delegate = self
		self.register(RecommendationCell.self, forCellWithReuseIdentifier: RecommendationCell.identifier)
		self.translatesAutoresizingMaskIntoConstraints = false
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func setData(viewController controller: MainViewController, viewModel vm: MainViewModel, data: SPTAppRemoteContentItem) {
		self.viewController = controller
		self.data = data
		self.viewModel = vm
		DispatchQueue.main.async { [weak self] in
			self?.reloadData()
		}
	}

	// MARK: - UICollectionViewDataSource
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let data = self.data?.children else { return 0 }
		return data.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let data = self.data?.children, let cell = self.dequeueReusableCell(withReuseIdentifier: RecommendationCell.identifier, for: indexPath) as? RecommendationCell else {
			return UICollectionViewCell()
		}
		if data.count > indexPath.row {
			cell.setData(vm: self.viewModel, data[indexPath.row])
			cell.bindViewModel()
		}
		return cell
	}

	// MARK: - UICollectionViewDelegateFlowLayout
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: Spacing.Size.width, height: Spacing.Size.height)
	}

	// MARK: - UICollectionViewDelegate
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let data = self.data?.children else { return }
		let vc = ListViewController(item: data[indexPath.row])
		let cell = collectionView.cellForItem(at: indexPath) as? RecommendationCell
		self.viewController?.navigationController?.pushViewController(vc, animated: true)

		cell?.unBindViewModel()
		viewModel = nil
		viewController = nil
	}
}

